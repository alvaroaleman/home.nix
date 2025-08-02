{
  description = "My Home manager configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-plugin-gruvbox = {
      url = "github:ellisonleao/gruvbox.nvim/6d409ee8af4e84d2327b4b5856f843b97a85a567";
      flake = false;
    };

    nix-search-cli.url = "github:peterldowns/nix-search-cli";
  };
  outputs = {
    nixpkgs,
    home-manager,
    nvim-plugin-gruvbox,
    nix-search-cli,
    ...
  }: let
    # Common module args for all configurations
    commonModuleArgs = {
      inherit nvim-plugin-gruvbox nix-search-cli;
    };
  in {
    # Export it
    homeManagerModules.default = {
      imports = [./home.nix];
      _module.args = commonModuleArgs;
    };

    # Local darwin deployment target
    homeConfigurations."alvaro@darwin" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
      };
      modules = [
        {
          home.username = "alvaro";
        }
        ./home.nix
        {
          _module.args = commonModuleArgs;
        }
      ];
    };
  };
}
