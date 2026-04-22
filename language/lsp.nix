{
    diagnostic.settings = {
        signs = true;
        underline = true;
        virtual_text = true;
        severity_sort = true;
        update_in_insert = true;
    };

    lsp = {
        inlayHints.enable = true;
        servers = {
            nixd = {
                enable = true;
                config = {
                    cmd = [
                        "nixd"
                        "--semantic-tokens=true"
                    ];
                    settings.nixd = let in {
                        nixpkgs.expr = ''
                            import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }
                        ''; # upon editing flakes - tells nixd which nixpkgs to use for completions
                    };
                };
            };
        };
    };
}
