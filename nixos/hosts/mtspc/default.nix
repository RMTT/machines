{ pkgs, lib, config, modules, ... }: {
  imports = with modules;[
    base
    fs
    networking
    plasma
    nvidia
    pipewire
    developments
    services
    docker
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

  boot.kernel.sysctl = {
    "kernel.yama.ptrace_scope" = 0;
  };

  # default shell
  users.users.mt.shell = pkgs.zsh;

  # kernel version
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    device = "nodev";
    efiSupport = true;
  };

  # nvidia
  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.latest;

  hardware.cpu.amd.updateMicrocode = true;

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # for wechat-uos
  ];
  # additional system packages
  environment.systemPackages = with pkgs; [
    config.boot.kernelPackages.perf
    moonlight-qt
    config.nur.repos.xddxdd.wechat-uos
  ];

  programs.steam = {
    enable = true;
    extest.enable = true;
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  virtualisation.docker = {
    storageDriver = "btrfs";
  };

  # kvm settings
  boot.kernelModules = [ "kvm_amd" ];

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemuHook = ./scripts/vfio_auto_bind.sh;

  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  programs.clash-verge = {
    package = pkgs.fresh.clash-verge-rev;
    enable = true;
    tunMode = true;
  };
  networking.firewall.trustedInterfaces = [ "Meta" "virbr0" ];
}
