{ pkgs, lib, ... }:
with lib; {
  imports =
    [ ./modules/secrets.nix ./modules/base.nix ./modules/networking.nix ];

  config = {
    base.gl.enable = false;

    # disable docker
    virtualisation.docker.enable = mkForce false;

    networking.useDHCP = mkForce true;

    environment.systemPackages = with pkgs; [ nixos-install-tools ];
  };
}
