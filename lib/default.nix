{ self
, nixpkgs
, nixpkgs-fresh
, home-manager
, nur
, sops-nix
, disko
, ...
}@inputs:
let
  modulePath = ../nixos/modules;
  secretsPath = ../secrets/secrets.nix;

  modules = {
    base = modulePath + "/base.nix";
    fs = modulePath + "/fs.nix";
    networking = modulePath + "/networking.nix";
    plasma = modulePath + "/plasma.nix";
    nvidia = modulePath + "/nvidia.nix";
    pipewire = modulePath + "/pipewire.nix";
    developments = modulePath + "/developments.nix";
    services = modulePath + "/services.nix";
    docker = modulePath + "/docker.nix";
    wireguard = modulePath + "/wireguard.nix";
    gravity = modulePath + "/gravity";
    globals = modulePath + "/globals";
    secrets = secretsPath;
  };

  overlay-libvterm = final: prev: {
    libvterm-neovim = prev.libvterm-neovim.overrideAttrs
      (finalAttrs: oldAttrs: {
        src = prev.fetchgit {
          url = "https://github.com/RMTT/libvterm";
          rev = "f85948154c22549d126a2ef3ebdf09952c6b237c";
          hash = "sha256-iC6LC5B7ZcRIFwTaHxSq9Ax59NBpEfS0LwMEB1b+fvw=";
        };
      });
  };

in
{
  mkSystem = name: system: extraModules:
    let
      collectFlakeInputs = input: [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));

      overlay-fresh = final: prev: {
        fresh = import nixpkgs-fresh {
          inherit system;
          config.allowUnfree = true;
        };
      };

      overlay-ownpkgs = final: prev: self.packages.${system};
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        modules = modules;
      };
      modules = [
        ../nixos/hosts/${name}/default.nix
        nur.nixosModules.nur
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ overlay-fresh overlay-ownpkgs ];

          # keep flake sources in system closure
          # https://github.com/NixOS/nix/issues/3995
          system.extraDependencies = builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);
        })
        {
          nix.registry =
            builtins.mapAttrs (name: value: { flake = value; }) inputs;
          networking.hostName = name;
        }
      ] ++ extraModules;
    };

  mkUser = name: system:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs-fresh { inherit system; };
      extraSpecialArgs.sops = sops-nix.homeManagerModules.sops;
      modules = [
        {
          nixpkgs.overlays = [ overlay-libvterm ];
          home.username = name;
          home.homeDirectory = "/home/${name}";
          programs.home-manager.enable = true;
        }
        inputs.plasma-manager.homeManagerModules.plasma-manager
        ../home/${name}.nix
      ];
    };
}

