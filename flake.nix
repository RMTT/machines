{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, nur
    , ... }@inputs:
    with flake-utils.lib;
    let
      mkSystem = name: system: nixosVersion: extraModules:
        nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs.pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
          specialArgs.ownpkgs = self.packages.${system};
          modules = [
            ./nixos/${name}.nix
            nur.nixosModules.nur
            { system.stateVersion = nixosVersion; }
            { networking.hostName = name; }
          ] ++ extraModules;
        };
    in {
      nixosConfigurations.mtswork =
        mkSystem "mtswork" system.x86_64-linux "22.11" [
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs.pkgs-unstable =
              nixpkgs-unstable.legacyPackages.${system.x86_64-linux};
            home-manager.extraSpecialArgs.plasma-manager =
              inputs.plasma-manager.homeManagerModules.plasma-manager;
          }
        ];
    } // eachSystem [ system.x86_64-linux ] (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };
      in {
        formatter = pkgs.nixfmt;
        packages.apple-fonts = pkgs.callPackage ./packages/apple-fonts.nix { };
      });
}
