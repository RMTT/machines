{ pkgs, ... }: {
  imports = [
    ../modules/base.nix
    ../modules/boot.nix
    ../modules/fs-btrfs.nix
    ../modules/networking.nix
    ../modules/desktop.nix
    ../modules/nvidia.nix
    ../modules/pipewire.nix
    ../modules/developments.nix
  ];

  # set boot device
  boot.device = "A097-4BAA";

  # set filesystems mount
  fs.btrfs.device = "cf700dce-c94e-499f-8550-3f59e5054961";
  fs.btrfs.volumes = {
    "/" = [ "subvol=@" ];
    "/home" = [ "subvol=@home" ];
  };

  # kernel version
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # hardware settings
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = with pkgs; [
    mesa.drivers
    intel-ocl
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    vaapiVdpau
    libvdpau-va-gl
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

  security.sudo.extraRules = [{
    users = [ "mt" ];
    commands = [{
      command = "ALL";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }];

  # configure SDDM
  services.xserver.displayManager.sddm.settings = {
    X11.ServerArguments = "-nolisten tcp -dpi 144";
    Theme.CursorTheme = "breeze_cursors";
  };

  # enable tlp
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  # enable home-manager for users
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.mt = import ../users/mt.nix;
}
