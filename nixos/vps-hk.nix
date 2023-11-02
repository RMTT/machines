{ pkgs, lib, config, ... }:
with lib; {
  imports = [
    ./modules/secrets.nix
    ./modules/base.nix
    ./modules/fs.nix
    ./modules/networking.nix
  ];

  base.gl.enable = false;

  fs.normal.volumes = {
    "/" = {
      fsType = "ext4";
      device = "@";
      options =
          [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
    };
  };
	fs.swap.device = "@swap";
  fs.boot.device = "@boot";

  hardware.cpu.intel.updateMicrocode = true;
}
