{ pkgs, ... }: rec {
  imports = [
    ./modules/secrets.nix
    ./modules/base.nix
    ./modules/fs.nix
    ./modules/networking.nix
    ./modules/gnome.nix
    ./modules/nvidia.nix
    ./modules/pipewire.nix
    ./modules/developments.nix
    ./modules/services.nix
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

  hardware.cpu.amd.updateMicrocode = true;

  # additional system packages
  environment.systemPackages = [ boot.kernelPackages.perf ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  # enable v2ray
  services.v2raya.enable = true;

  # set gdm scale
  desktop.gdm.scale = 2;
  desktop.gdm.avatar = "mt";

  home-manager.users.mt = import ../home/mt.nix;

  virtualisation.docker.storageDriver = "btrfs";

  # nvidia setting
  nvidia.usage = "compute";

  # kvm settings
  boot.kernelModules = [ "kvm_amd" ];

  base.libvirt.enable = true;
  base.libvirt.qemuHook = ./scripts/vfio_auto_bind.sh;

  base.onedrive.enable = true;

  services.cockpit.enable = true;
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = { interfaces = [ "enp38s0" ]; };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [{
        pools = [{ pool = "192.168.6.10 - 192.168.6.240"; }];
        subnet = "192.168.6.1/24";
      }];
      valid-lifetime = 4000;
    };
  };
}
