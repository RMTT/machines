{ lib, ... }:
with lib; {
  imports = [ ./modules/base.nix ./modules/networking.nix ];

  config = {
    base.gl.enable = false;

    base.mt.password = false;
    users.users.mt.password = "nixos";

    # disable docker
    virtualisation.docker.enable = mkForce false;
  };
}
