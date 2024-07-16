{ pkgs, ... }: {
  metacubexd = pkgs.callPackage ./metacubexd.nix { };
  derper = pkgs.callPackage ./derp.nix { };
  udp2raw-bin = pkgs.callPackage ./udp2raw-bin.nix { };
  zoom-us = pkgs.callPackage ./zoom.nix { };
}
