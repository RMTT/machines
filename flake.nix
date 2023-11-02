{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-23.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";

    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, flake-utils, home-manager, nur
    , sops-nix, ... }@inputs:
    with flake-utils.lib;
    let
      stateVersion = "23.05";

      lib = import ./packages/lib.nix inputs;

      nixosConfigurations = {
        mtswork = lib.mkSystem "mtswork" system.x86_64-linux stateVersion [ ];

        mtspc = lib.mkSystem "mtspc" system.x86_64-linux stateVersion [ ];

        homeserver =
          lib.mkSystem "homeserver" system.x86_64-linux stateVersion [ ];

        router = lib.mkSystem "router" system.x86_64-linux stateVersion [ ];

        vps-hk = lib.mkSystem "vps-hk" system.x86_64-linux stateVersion [ ];

        live = lib.mkSystem "live" system.x86_64-linux stateVersion [ ];
      };

      homeConfigurations = {
        mt = lib.mkUser "mt" system.x86_64-linux stateVersion;
      };
    in {
      nixosConfigurations = nixosConfigurations;
      homeConfigurations = homeConfigurations;
    } // eachSystem [ system.x86_64-linux ] (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };
      in {
        formatter = pkgs.nixfmt;
        packages.metacubexd = pkgs.callPackage ./packages/metacubexd.nix { };
        packages.zoom-us = pkgs.callPackage ./packages/zoom-us.nix { };
      });
}
