{ pkgs, ... }: {
  imports = [
    ../modules/base.nix
    ../modules/boot.nix
    ../modules/fs-btrfs.nix
    ../modules/networking.nix
  ];

  # set boot device
  boot.device = "A097-4BAA";

  # set filesystems mount
  fs.btrfs.device = "cf700dce-c94e-499f-8550-3f59e5054961";
  fs.btrfs.volumes = {
    "/" = [ "subvol=@" ];
    "/home" = [ "subvol=@home" ];
  };

  # set hostname
  networking.hostName = "mt01";
}
