{ lib, pkgs, ... }:
let
  diagnostics = {
    diagnostic.settings = {
      signs = true;
      underline = true;
      virtual_text = false; # handled with K hover and <leader>d for global diagnostics
      severity_sort = true;
      update_in_insert = true;
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
        options.desc = "toggle global diagnostics";
      }
    ];
  };

  lsp = {
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
          config.settings.Lua = {
            telemetry = {
              enable = false;
            };
            diagnostics.globals = [ "vim" ];
            workspace = {
              library = "${pkgs.neovim}/share/nvim/runtime";
            };
            checkThirdParty = false;
            hints = {
              enable = true;
              arrayIndex = "enable";
              setType = true;
              paramName = "All";
              paramType = true;
            };
          };
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
  };

  code_injection = {
    plugins.otter.enable = true;
    extraConfigLua = ''
      local ns = vim.api.nvim_create_namespace("lua_injection")
      local borders = true

      local function highlight_lua_injections(bufnr)
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        local parser = vim.treesitter.get_parser(bufnr, "nix")
        if not parser then return end
        parser:parse(true)
        local lua_tree = parser:children()["lua"]
        if not lua_tree then return end

        local win_width = vim.api.nvim_win_get_width(0)
        for _, tree in ipairs(lua_tree:trees()) do
          local root = tree:root()
          local sr, sc, er, ec = root:range()
          local line_count = er - sr

          if line_count > 2 then
            vim.api.nvim_buf_set_extmark(bufnr, ns, sr, sc, {
              end_row = er - 1,
              end_col = ec,
              line_hl_group = "InjectedContent",
              priority = 0,
            })

            if borders then
              vim.api.nvim_buf_set_extmark(bufnr, ns, sr, 0, {
              virt_lines_above = true,
              virt_lines = {
                {
                  { " lua ", "InjectedBorderTitle" },
                  { string.rep("─", win_width - 5), "InjectedBorder"},
                },
              },
            })
              vim.api.nvim_buf_set_extmark(bufnr, ns, er-1, 0, {
                virt_lines = {
                  {
                    { string.rep("─", win_width), "InjectedBorder" },
                  },
                },
              })
            end
          else
            vim.api.nvim_buf_set_extmark(bufnr, ns, sr, sc, {
              end_row = er,
              end_col = ec,
              hl_group = "InjectedInlineContent",
              priority = 0,
            })
          end
        end
      end

      vim.api.nvim_set_hl(0, "InjectedContent", {bg = "#111111", italic = true})
      vim.api.nvim_set_hl(0, "InjectedInlineContent", {italic = true})
      vim.api.nvim_set_hl(0, "InjectedBorder", {bg = "#111111", fg = "#808080", italic = true})
      vim.api.nvim_set_hl(0, "InjectedBorderTitle", {bg = "#111111", fg = "#808080", italic = true})

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "nix",
        callback = function(ev)
          vim.api.nvim_create_autocmd("LspAttach", {
            buffer = ev.buf,
            callback = function(args)
              if not args.data or not args.data.client_id then return end
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if not client or client.name ~= "lua_ls" then return end
              require("otter").activate({ "lua" }, true, true, nil, client)
              return true
            end,
          })
          highlight_lua_injections(ev.buf)
          vim.api.nvim_buf_attach(ev.buf, false, {
            on_bytes = function()
              vim.schedule(function()
                highlight_lua_injections(ev.buf)
              end)
            end,
          })
        end,
      })
    '';
  };

  formaters = {
    extraPackages = with pkgs; [
      nixfmt
      stylua
    ];

    plugins = {
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft.nix = [
            "nixfmt"
            "injected" # for otter injected lua
          ];
          formatters_by_ft.lua = [ "stylua" ];
          formatters.injected.options = {
            lang_to_ext = {
              lua = "lua";
            };
          };
        };
      };
    };

    keymaps = [
      {
        key = "<leader>f";
        action.__raw = ''
          function()
            require("conform").format({ async = true })
          end
        '';
        options.desc = "format buffer or embedded block";
      }
    ];
  };

  completion = {
    plugins.cmp = {
      enable = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "buffer"; }
          { name = "path"; }
          { name = "otter"; }
        ];
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
        };
      };
    };
    plugins.cmp-nvim-lsp.enable = true;
    plugins.cmp-buffer.enable = true;
    plugins.cmp-path.enable = true;

    extraConfigLua = ''
      vim.defer_fn(function()
          local clients = vim.lsp.get_clients()
          for _, c in ipairs(clients) do
              print(c.name .. ': ' .. vim.inspect(c.capabilities.textDocument.completion.completionItem.snippetSupport))
          end
      end, 1000)
    '';
  };

  parser = {
    plugins = {
      treesitter = {
        enable = true;
        settings = {
          highlight = {
            enable = true;
          };
          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            lua
            nix
          ];
        };
      };
    };
  };
in
lib.mkMerge [
  lsp
  code_injection
  formaters
  diagnostics
  completion
  parser
]
