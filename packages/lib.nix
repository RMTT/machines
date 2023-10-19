{ self, nixpkgs, nixpkgs-stable, flake-utils, home-manager, nur, sops-nix }: {
  mkSystem = name: system: nixosVersion: extraModules:
    let
      overlay-stable = final: prev: {
        stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      overlay-ownpkgs = final: prev: { ownpkgs = self.packages.${system}; };
    in nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ../nixos/${name}.nix
        nur.nixosModules.nur
        sops-nix.nixosModules.sops
				home-manager.nixosModules.home-manager
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ overlay-stable overlay-ownpkgs ];
        })
        { system.stateVersion = nixosVersion; }
        { networking.hostName = name; }
        {
          nix.registry = {
            self.flake = self;
            nixpkgs.flake = nixpkgs;

            nixpkgs-stable.flake = nixpkgs-stable;
          };
        }

      ] ++ extraModules;
    };

  mkUser = name: system: stateVersion:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; };
      extraSpecialArgs.sops = sops-nix.homeManagerModules.sops;
      modules = [
        {
					home.stateVersion = stateVersion;
					home.username = name;
					home.homeDirectory = "/home/${name}";
        }
        ../home/${name}.nix
      ];
    };
}
