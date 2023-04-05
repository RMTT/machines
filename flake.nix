{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }:
    with flake-utils.lib;
    eachSystem [ system.x86_64-linux ] (system:
      let
        pkgs = import nixpkgs { system = system; };
        pkgs-unstable = import nixpkgs-unstable { system = system; };
      in {
        formatter = pkgs.nixfmt;
        nixosConfigurations.vmw-laptop = pkgs.lib.nixosSystem {
          system = system;
          modules = [ ./nixos/vmw-laptop.nix ];
        };
      });

}
