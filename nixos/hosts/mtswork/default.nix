{ config, pkgs, modules, lib, ... }: {
  imports = with modules; [
    base
    fs
    networking
    plasma
    nvidia
    docker
    pipewire
    developments
    services
  ];

  system.stateVersion = "23.05";

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
  hardware.graphics.extraPackages = with pkgs; [
    intel-ocl
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  ];

  hardware.cpu.intel.updateMicrocode = true;

  # additional kernel modules
  boot.kernelModules = [ "kvm-intel" "i915" ];

  # nvidia related
  hardware.nvidia = {
    powerManagement.enable = lib.mkForce false;
    prime = {
      intelBusId = "PCI:0:2:0";

      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.xserver.videoDrivers = [ "intel" ];

  # enable tlp
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  virtualisation.docker.storageDriver = "btrfs";

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # for wechat-uos
  ];
  environment.systemPackages = with pkgs; [ kubernetes rclone steam config.nur.repos.xddxdd.wechat-uos ];


  # default shell
  users.users.mt.shell = pkgs.zsh;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  boot.blacklistedKernelModules = [
    "intel_hid"
  ];

  programs.clash-verge = {
    package = pkgs.fresh.clash-verge-rev;
    enable = true;
    tunMode = true;
  };
  networking.firewall.trustedInterfaces = [ "Meta" ];
}

