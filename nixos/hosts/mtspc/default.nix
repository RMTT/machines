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
    "/" = [ "subvol=@" "rw" "relatime" "ssd" "space_cache=v2" ];
    "/home" = [ "subvol=@home" "rw" "relatime" "ssd" "space_cache=v2" ];
  };
  fs.swap.label = "@swap";
  fs.boot.label = "@boot";

  boot.kernel.sysctl = {
    "kernel.yama.ptrace_scope" = 0;
  };
  boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
  boot.kernelParams = [
    "amd_pstate=guided"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvme_core.default_ps_max_latency_us=0"
    "pcie_aspm=off"
    "pcie_port_pm=off"
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
    powerManagement = {
      enable = true;
    };
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # default shell
  users.users.mt.shell = pkgs.zsh;

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
