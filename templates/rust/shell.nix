{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs = [ pkgs.cargo pkgs.rustc ];
  nativeBuildInputs = with pkgs.buildPackages; [ pkg-config ];
}

