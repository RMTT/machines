{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-23.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  };

  outputs =
    { self, nixpkgs, nixpkgs-stable, flake-utils, home-manager, ... }@inputs:
    with flake-utils.lib;
    let
      mkSystem = name: system: nixosVersion: extraModules:
        nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs.pkgs-stable = import nixpkgs-stable {
            system = "${system}";
            config.allowUnfree = true;
          };

          specialArgs.ownpkgs = self.packages.${system};
          specialArgs.inputs = inputs;
          modules = [
            ./nixos/${name}.nix
            inputs.sops-nix.nixosModules.sops
            { system.stateVersion = nixosVersion; }
            { networking.hostName = name; }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs.pkgs-stable =
                import nixpkgs-stable {
                  system = "${system}";
                  config.allowUnfree = true;
                };
							home-manager.extraSpecialArgs.ownpkgs = self.packages.${system};

              home-manager.extraSpecialArgs.plasma-manager =
                inputs.plasma-manager.homeManagerModules.plasma-manager;

              home-manager.extraSpecialArgs.sops =
                inputs.sops-nix.homeManagerModules.sops;

              home-manager.extraSpecialArgs.stateVersion = nixosVersion;
            }
          ] ++ extraModules;
        };
    in {
      nixosConfigurations = {
        mtswork = mkSystem "mtswork" system.x86_64-linux "23.05" [ ];

        mtspc = mkSystem "mtspc" system.x86_64-linux "23.05" [ ];

        homeserver = mkSystem "homeserver" system.x86_64-linux "23.05" [ ];

        router = mkSystem "router" system.x86_64-linux "23.05" [ ];

        live = mkSystem "live" system.x86_64-linux "23.05" [ ];
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
        packages.yacd-meta = pkgs.callPackage ./packages/yacd-meta.nix { };
				packages.zoom-us = pkgs.callPackage ./packages/zoom-us.nix { };
      });
}
