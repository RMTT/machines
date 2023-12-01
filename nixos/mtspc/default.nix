{ pkgs, lib, config, ... }: rec {
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
    ../modules/docker.nix
  ];

  # set filesystems mount
  fs.btrfs.label = "@";
  fs.btrfs.volumes = {
    "/" = [ "subvol=@" "rw" "relatime" "ssd" "space_cache=v2" ];
    "/home" = [ "subvol=@home" "rw" "relatime" "ssd" "space_cache=v2" ];
  };
  fs.swap.label = "@swap";
  fs.boot.label = "@boot";

  # default shell
  users.users.mt.shell = pkgs.zsh;

  # kernel version
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    device = "nodev";
    efiSupport = true;
  };

  hardware.cpu.amd.updateMicrocode = true;

  # additional system packages
  environment.systemPackages = with pkgs; [
    boot.kernelPackages.perf
    moonlight-qt
    vmware-horizon-client
  ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  # enable v2ray
  services.v2raya.enable = true;

  virtualisation.docker.storageDriver = "btrfs";

  # kvm settings
  boot.kernelModules = [ "kvm_amd" ];

  nvidia.usage = "compute";
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemuHook = ./scripts/vfio_auto_bind.sh;
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  environment.etc = {
    "NetworkManager/dnsmasq.d/vmware".text =
      "	server=/vmware.com/10.117.0.38\n	server=/vmware.com/10.117.0.39\n";
  };
}
