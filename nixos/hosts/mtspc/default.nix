{ pkgs, lib, config, modules, ... }: {
  imports = with modules;[
    base
    fs
    networking
    plasma
    pipewire
    developments
    services
    docker
  ];

  system.stateVersion = "23.05";

  # set filesystems mount
  fs.btrfs.label = "@";
  fs.btrfs.volumes = {
    "/" = [ "subvol=@" "compress=zstd" "rw" "relatime" "ssd" "space_cache=v2" ];
    "/home" = [ "subvol=@home" "compress=zstd" "rw" "relatime" "ssd" "space_cache=v2" ];
  };
  fs.boot.label = "@BOOT";
  fs.swap.label = "@SWAP";

  boot.kernel.sysctl = {
    "kernel.yama.ptrace_scope" = 0;
  };
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  boot.kernelParams = [
    "amd_pstate=active"
  ];
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";
  # kernel version
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  hardware.cpu.amd.updateMicrocode = true;

  base.gl.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  boot.initrd.kernelModules = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:6:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
    powerManagement = {
      enable = true;
    };
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # default shell
  users.users.mt.shell = pkgs.zsh;

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


  virtualisation.docker = {
    storageDriver = "btrfs";
  };

  virtualisation.libvirtd.enable = true;

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
  networking.firewall.trustedInterfaces = [ "Meta" ];

  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
}
