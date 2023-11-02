{ pkgs, lib, ... }: {
  imports = [
    ./modules/secrets.nix
    ./modules/base.nix
    ./modules/networking.nix
    ./modules/fs.nix
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

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.device = "/dev/sda";
}
