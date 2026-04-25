{
    diagnostic.settings = {
        signs = true;
        underline = true;
        virtual_text = false;
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
                    settings.nixd = let
                        flakeExpr = "builtins.getFlake (toString ./.)";
                    in {
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

    plugins = {
        # default setting for many lsps
        lspconfig = {
            enable = true;
        };

        trouble.enable = true;
        conform-nvim = {
            enable = true;
            settings.formatters_by_ft.nix = [ "nixfmt" ];
        };
    };

    keymaps = [
        { key = "gd"; action.__raw = "vim.lsp.buf.definition"; mode = "n"; }
        { key = "gr"; action.__raw = "vim.lsp.buf.references"; mode = "n"; }
        { key = "K"; action.__raw = "vim.lsp.buf.hover"; mode = "n"; }
        { key = "gi"; action.__raw = "vim.lsp.buf.implementation"; mode = "n"; }
        { key = "<leader>rn"; action.__raw = "vim.lsp.buf.rename"; mode = "n"; }
        { key = "<leader>ca"; action.__raw = "vim.lsp.buf.code_action"; mode = "n"; }
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
                        vim.diagnostic.config({ virtual_text = true })

                        vim.defer_fn(function()
                            vim.diagnostic.config({ virtual_text = false })
                        end, 2500)
                    end
                '';
            };
            options.desc = "Show global diagnostics temporarily";
        }
    ];
}
