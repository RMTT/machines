{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, ... }@inputs:
    with flake-utils.lib;
    let
      mkSystem = name: system: nixosVersion: extraModules:
        nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs.pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
          specialArgs.ownpkgs = self.packages.${system};
          modules = [
            ./nixos/${name}.nix
            inputs.sops-nix.nixosModules.sops
            { system.stateVersion = nixosVersion; }
            { networking.hostName = name; }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs.pkgs-unstable =
                nixpkgs-unstable.legacyPackages.${system};

              home-manager.extraSpecialArgs.plasma-manager =
                inputs.plasma-manager.homeManagerModules.plasma-manager;

              home-manager.extraSpecialArgs.sops =
                inputs.sops-nix.homeManagerModules.sops;
            }
          ] ++ extraModules;
        };
    in {
      nixosConfigurations = {
        mtswork = mkSystem "mtswork" system.x86_64-linux "22.11" [ ];

        mtspc = mkSystem "mtspc" system.x86_64-linux "22.11" [ ];

        homeserver = mkSystem "homeserver" system.x86_64-linux "22.11" [ ];
      };
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
