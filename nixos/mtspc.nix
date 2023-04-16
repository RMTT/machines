{ pkgs, ... }: {
  imports = [
    ../modules/base.nix
    ../modules/boot.nix
    ../modules/fs.nix
    ../modules/networking.nix
    ../modules/desktop.nix
    ../modules/nvidia.nix
    ../modules/pipewire.nix
    ../modules/developments.nix
    ../modules/services.nix
  ];

  # set filesystems mount
  fs.btrfs.device = "@";
  fs.btrfs.volumes = {
    "/" = [ "subvol=@" "rw" "relatime" "ssd" "space_cache=v2" ];
    "/home" = [ "subvol=@home" "rw" "relatime" "ssd" "space_cache=v2" ];
  };
  fs.swap.device = "@swap";
  fs.boot.device = "@boot";

  # kernel version
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # hardware settings
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    mesa.drivers
    vaapiVdpau
    libvdpau-va-gl
  ];

  hardware.cpu.amd.updateMicrocode = true;

  # additional kernel modules
  boot.kernelModules = [ "kvm-amd" ];

  # additional system packages
  environment.systemPackages = with pkgs; [ glxinfo ];

  # nvidia related
  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:36:0:0";

    nvidiaBusId = "PCI:45:0:0";
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  security.sudo = { wheelNeedsPassword = false; };

  # enable v2ray
  services.v2raya.enable = true;

  # enable home-manager for users
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.mt = import ../users/mt.nix;

  virtualisation.docker.storageDriver = "btrfs";
}
