{ pkgs, ... }:
{
  diagnostic.settings = {
    signs = true;
    underline = true;
    virtual_text = false; # handled with K hover and <leader>d for global diagnostics
    severity_sort = true;
    update_in_insert = true;
  };

  lsp = {
    inlayHints.enable = true;
    servers = {
      "*" = {
        config = {
          # have locally installed lsp's run first!
          packageFallback = true;
        };
      };
      lua_ls = {
        enable = true;
      };
      nixd = {
        enable = true;
        config = {
          cmd = [
            "nixd"
            "--semantic-tokens=true"
          ];
          settings.nixd =
            let
              flakeExpr = "builtins.getFlake (toString ./.)";
            in
            {
              # available packages options
              nixpkgs.expr = ''
                import (${flakeExpr}).inputs.nixpkgs { }
              '';

              # nixvim configuration (loads all plugin options)
              options.nixvim.expr = ''
                let
                    flake = ${flakeExpr};
                    system = builtins.currentSystem;
                in
                if (
                    builtins.hasAttr "packages" flake
                    && builtins.hasAttr system flake.packages
                    && builtins.hasAttr "default" flake.packages.''${system}
                )
                then flake.packages.''${system}.default.options
                else {}
              '';
            };
        };
      };
    };
  };

  # formatters
  extraPackages = with pkgs; [
    nixfmt
  ];

  plugins = {
    # default setting for many lsps
    lspconfig = {
      enable = true;
    };

    conform-nvim = {
      enable = true;
      settings.formatters_by_ft.nix = [ "nixfmt" ];
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "K";
      action = {
        __raw = ''
          function()
              vim.diagnostic.open_float(nil, {
                  focus = false,
                  scope = "cursor",
                  border = "none",
              })
          end
        '';
      };
      options.desc = "Show local diagnostic under cursor";
    }
    {
      mode = "n";
      key = "<leader>d";
      action = {
        __raw = ''
          function()
              vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
          end
        '';
      };
      options.desc = "Show global diagnostics temporarily";
    }
    {
      key = "<leader>f";
      action.__raw = ''
        function()
          require("conform").format({ async = true })
        end
      '';
      options.desc = "format buffer";
    }
    {
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
    }
  ];
}
