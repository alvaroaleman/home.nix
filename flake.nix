{
  description = "My Home manager configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-search-cli.url = "github:peterldowns/nix-search-cli";

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };
  outputs = {
    nixpkgs,
    home-manager,
    nix-search-cli,
    nix-flatpak,
    ...
  }: {
    nixosConfigurations.x1c = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./x1c-configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.alvaro = import ./home.nix;
          home-manager.extraSpecialArgs = {inherit nix-search-cli nix-flatpak;};
        }
      ];
    };
  };
}
