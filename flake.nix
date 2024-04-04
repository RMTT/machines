{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";

    nur.url = "github:nix-community/NUR";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , flake-utils
    , home-manager
    , nur
    , sops-nix
    , ...
    }@inputs:
      with flake-utils.lib;
      let

        lib = import ./packages/lib.nix inputs;

        nixosConfigurations = {
          mtswork = lib.mkSystem "mtswork" system.x86_64-linux [ ];

          mtspc = lib.mkSystem "mtspc" system.x86_64-linux [ ];

          homeserver =
            lib.mkSystem "homeserver" system.x86_64-linux [ ];

          router = lib.mkSystem "router" system.x86_64-linux [ ];

          vps-hk = lib.mkSystem "vps-hk" system.x86_64-linux [ ];

          portal = lib.mkSystem "portal" system.x86_64-linux [ ];

          live = lib.mkSystem "live" system.x86_64-linux [ ];
        };

        homeConfigurations = {
          mt = lib.mkUser "mt" system.x86_64-linux;
        };
      in
      {
        nixosConfigurations = nixosConfigurations;
        homeConfigurations = homeConfigurations;
      } // eachSystem [ system.x86_64-linux ] (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        packages.metacubexd = pkgs.callPackage ./packages/metacubexd.nix { };
        packages.phantun = pkgs.callPackage ./packages/phantun.nix { };
      });
}
