{ pkgs, ... }: {
  metacubexd = pkgs.callPackage ./metacubexd.nix { };
  derper = pkgs.callPackage ./derp.nix { };
  udp2raw = pkgs.callPackage ./udp2raw-bin.nix { };
  zoom-us = pkgs.callPackage ./zoom.nix { };
  cider = pkgs.callPackage ./cider2.nix { };
  bird = pkgs.callPackage ./bird { };
}
