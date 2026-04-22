{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = { nixvim, nixpkgs, ... }:
    let
      nixvimModule = system: {
        inherit system;
        module = {
          imports = [
            ./navigation/shortcut-hints.nix
            ./navigation/cmd-line.nix
            ./theme/notifications.nix
            ./theme/fonts.nix
            ./language/lsp.nix
            ./language/autocompletion.nix
          ];
          nixpkgs.config.allowUnfree = true;
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
