{
  description = "My Home manager configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-search-cli.url = "github:peterldowns/nix-search-cli";
  };
  outputs = {
    nixpkgs,
    home-manager,
    darwin,
    nix-search-cli,
    ...
  }: let
    # Common module args for all configurations
    commonModuleArgs = {
      inherit nix-search-cli;
    };

    userList = ["alvaro" "aaleman"];

    mkMacHomeConfig = user: {
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
      };
      modules = [
        {
          home.username = user;
        }
        ./home.nix
        {
          _module.args = commonModuleArgs;
        }
      ];
    };

    macConfigs = builtins.listToAttrs (
      map (user: {
        name = "${user}@darwin";
        value = home-manager.lib.homeManagerConfiguration (mkMacHomeConfig user);
      })
      userList
    );

    mkLinuxConfig = user: {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      modules = [
        {
          home.username = user;
        }
        ./home.nix
        {
          _module.args = commonModuleArgs;
        }
      ];
    };

    linuxConfigs = builtins.listToAttrs (
      map (user: {
        name = "${user}@linux";
        value = home-manager.lib.homeManagerConfiguration (mkLinuxConfig user);
      })
      userList
    );

    mkDarwinConfig = user: {
      system = "aarch64-darwin";
      specialArgs = {inherit user;};
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = {
            imports = [./home.nix];
            _module.args = commonModuleArgs;
          };
        }
      ];
    };

    darwinConfigs = builtins.listToAttrs (
      map (user: {
        name = "${user}@darwin";
        value = darwin.lib.darwinSystem (mkDarwinConfig user);
      })
      userList
    );
  in {
    homeManagerModules.default = {
      imports = [./home.nix];
      _module.args = commonModuleArgs;
    };

    homeConfigurations = macConfigs // linuxConfigs;
    darwinConfigurations = darwinConfigs;
  };
}
