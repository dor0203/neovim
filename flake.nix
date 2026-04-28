{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    noob-nvim = {
      url = "github:dor0203/nvim-noob";
      flake = false;
    };
  };

  outputs = { nixvim, nixpkgs, noob-nvim, ... }@inputs:
    let
      nixvimModule = system: {
        inherit system;
        module = {...}: {
          imports = [
            ./navigation/shortcut-hints.nix
            ./navigation/cmd-line.nix
            ./theme.nix
            ./interactions.nix
            ./language/lsp.nix
            ./language/autocompletion.nix
            ./navigation/cheatsheet.nix
          ];

          opts.relativenumber = true;
          nixpkgs.config.allowUnfree = true;
          _module.args = {
            inherit inputs;
          };
        };
      };

      per_system = nixpkgs.lib.genAttrs nixpkgs.lib.systems.doubles.all;
      generate_config = system: {
        default =
          nixvim.legacyPackages.${system}.makeNixvimWithModule
            (nixvimModule system);
      };

    in {
      packages = per_system generate_config;
    };
}
