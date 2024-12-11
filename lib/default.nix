{ self, nixpkgs, nixpkgs-fresh, home-manager, nur, sops-nix, disko, ...
}@inputs:
let
  modulePath = ../nixos/modules;
  secretsPath = ../secrets/secrets.nix;

  modules = {
    base = modulePath + "/base.nix";
    fs = modulePath + "/fs.nix";
    networking = modulePath + "/networking.nix";
    desktop = modulePath + "/desktop";
    nvidia = modulePath + "/nvidia.nix";
    developments = modulePath + "/developments.nix";
    services = modulePath + "/services.nix";
    docker = modulePath + "/docker.nix";
    wireguard = modulePath + "/wireguard.nix";
    gravity = modulePath + "/gravity";
    globals = modulePath + "/globals";
    godel = modulePath + "/godel";
    secrets = secretsPath;
  };

  hmMoudles = name: [
    {
      nixpkgs.overlays = [ overlay-libvterm overlay-ownpkgs ];
      nixpkgs.config = { allowUnfree = true; };
      programs.home-manager.enable = true;
    }
    inputs.plasma-manager.homeManagerModules.plasma-manager
    nur.modules.homeManager.default
    {
      home.username = name;
      home.homeDirectory = "/home/${name}";
    }
    ../home/${name}.nix
  ];

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

  overlay-fresh = final: prev: {
    fresh = import nixpkgs-fresh {
      system = prev.system;
      config.allowUnfree = true;
    };
  };

  overlay-ownpkgs = final: prev: import ../packages prev;
in {
  mkSystem = name: system: nixpkgs:
    let
      collectFlakeInputs = input:
        [ input ] ++ builtins.concatMap collectFlakeInputs
        (builtins.attrValues (input.inputs or { }));

      overlay-lib = final: prev: {
        mkUser = name:
          { lib, ... }: {
            imports = hmMoudles name;
            _module.args.pkgs = lib.mkForce (import nixpkgs-fresh {
              inherit system;
              config.allowUnfree = true;
            });
          };
      };
    in nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        modules = modules;
        inherit inputs;
      };
      modules = [
        ../nixos/hosts/${name}/default.nix
        nur.modules.nixos.default
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        inputs.daeuniverse.nixosModules.dae
        inputs.daeuniverse.nixosModules.daed
        {
          # home-manager settings
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
        ({ ... }: {
          nixpkgs.overlays = [
            overlay-fresh
            overlay-ownpkgs
            overlay-lib
          ];

          # keep flake sources in system closure
          # https://github.com/NixOS/nix/issues/3995
          system.extraDependencies =
            builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);
        })
        {
          # nixpkgs will be added automatically
          nix.registry = builtins.mapAttrs (name: value: { flake = value; })
            (builtins.removeAttrs inputs [ "nixpkgs" ]);
          networking.hostName = name;
        }
      ];
    };

  mkUser = name: system:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs-fresh {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs; };
      modules = hmMoudles name;
    };
}
