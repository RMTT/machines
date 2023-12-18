{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/secrets.nix
    ../modules/base.nix
    ../modules/fs.nix
    ../modules/networking.nix
    ../modules/gnome.nix
    ../modules/nvidia.nix
    ../modules/pipewire.nix
    ../modules/developments.nix
    ../modules/services.nix
  ];

  # set filesystems mount
  fs.btrfs.label = "@";
  fs.btrfs.volumes = {
    "/" = [ "subvol=@" "rw" "relatime" "ssd" "space_cache=v2" ];
    "/home" = [ "subvol=@home" "rw" "relatime" "ssd" "space_cache=v2" ];
  };
  fs.swap.label = "@swap";
  fs.boot.label = "@boot";

  # kernel version
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # hardware settings
  hardware.opengl.extraPackages = with pkgs; [
    intel-ocl
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  ];

  hardware.cpu.intel.updateMicrocode = true;

  # additional kernel modules
  boot.kernelModules = [ "kvm-intel" "i915" ];

  # additional system packages
  environment.systemPackages = with pkgs; [ glxinfo ];

  # nvidia related
  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";

    nvidiaBusId = "PCI:1:0:0";
  };

  services.xserver.videoDrivers = [ "intel" ];

  # enable tlp
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  # enable v2ray
  services.v2raya.enable = true;

  virtualisation.docker.storageDriver = "btrfs";
}
