{ pkgs, lib, config, modules, ... }: {
  imports = with modules; [
    globals
    base
    fs
    networking
    desktop
    developments
    services
    docker
    godel

    ./vm.nix
  ];

  system.stateVersion = "23.05";

  # set filesystems mount
  fs.btrfs.label = "@";
  fs.btrfs.volumes = {
    "/" = [ "subvol=@" "compress=zstd" "rw" "relatime" "ssd" "space_cache=v2" ];
    "/home" =
      [ "subvol=@home" "compress=zstd" "rw" "relatime" "ssd" "space_cache=v2" ];
  };
  fs.boot.label = "@BOOT";
  fs.swap.label = "@SWAP";

  boot.kernel.sysctl = { "kernel.yama.ptrace_scope" = 0; };
  boot.kernelParams = [ "amd_pstate=guided" ];
  hardware.cpu.amd.updateMicrocode = true;

  # kernel version
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  base.gl.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:8:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  desktop.niri.enable = true;

  # default shell
  users.users.mt.shell = pkgs.zsh;

  # additional system packages
  environment.systemPackages = with pkgs; [
    config.boot.kernelPackages.perf
    moonlight-qt
  ];

  programs.steam = {
    enable = true;
    extest.enable = true;
  };

  virtualisation.docker = { storageDriver = "btrfs"; };

  virtualisation.libvirtd.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  services.meshcentral.enable = true;
}
