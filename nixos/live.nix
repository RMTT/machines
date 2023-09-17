{ lib, ... }:
with lib; {
  imports =
    [ ./modules/secrets.nix ./modules/base.nix ./modules/networking.nix ];

  config = {
    base.gl.enable = false;

    base.mt.password = false;
    users.users.mt.password = "nixos";

    # disable docker
    virtualisation.docker.enable = mkForce false;

    networking.useDHCP = mkForce true;
  };
}
