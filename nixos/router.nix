{ pkgs, lib, ... }:
with lib; {
  imports = [ ./modules/base.nix ./modules/fs.nix ./modules/networking.nix ];

  config = {
    base.gl.enable = false;

    fs.normal.volumes = {
      "/" = {
        fsType = "ext4";
        device = "@";
        options = [ ];
      };
    };
    fs.boot.device = "@boot";

    hardware.cpu.intel.updateMicrocode = true;

    # disable network manager
    networking.networkmanager.enable = mkForce false;

    # disable docker
    virtualisation.docker.enable = mkForce false;

    # additional system packages
    environment.systemPackages = with pkgs; [ ppp ];
  };
}
