{ self, nixpkgs, nixpkgs-stable, flake-utils, home-manager, nur, sops-nix }:
let
  overlay-libvterm = final: prev: {
    libvterm-neovim = prev.libvterm-neovim.overrideAttrs
      (finalAttrs: oldAttrs: {
        src = prev.fetchgit {
          url = "https://github.com/RMTT/libvterm";
          rev = "21f196ed7e0d3cb4d6869cf5e0f04386f2e7ba2d";
					hash = "sha256-nL9WCiyzAhPvjCU9TXjIMOfLEZjN9DBXOSIvp4cFvvY=";
        };
      });
  };
in {
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
          nixpkgs.overlays = [ overlay-libvterm ];
          home.stateVersion = stateVersion;
          home.username = name;
          home.homeDirectory = "/home/${name}";
          programs.home-manager.enable = true;
        }
        ../home/${name}.nix
      ];
    };
}
