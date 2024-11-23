{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-fresh.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-fresh";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    daeuniverse.url = "github:daeuniverse/flake.nix";
    daeuniverse.inputs.nixpkgs.follows = "nixpkgs-fresh";
  };

  outputs =
    { self, nixpkgs, flake-utils, home-manager, nur, sops-nix, ... }@inputs:
    with flake-utils.lib;
    let

      lib = import ./lib inputs;

      nixosConfigurations = {
        mtspc = lib.mkSystem "mtspc" system.x86_64-linux [ ];

        homeserver = lib.mkSystem "homeserver" system.x86_64-linux [ ];

        router = lib.mkSystem "router" system.x86_64-linux [ ];

        cn2-la = lib.mkSystem "cn2-la" system.x86_64-linux [ ];

        mtslaptop = lib.mkSystem "mtslaptop" system.x86_64-linux [ ];

        # for nixd language server
        nixd = lib.mkSystem "nixd" system.x86_64-linux [ ];
      };

      homeConfigurations = { mt = lib.mkUser "mt" system.x86_64-linux; };
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
        formatter = pkgs.nixpkgs-fmt;
        packages = import ./packages pkgs;
      });
}
