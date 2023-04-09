{ config, pkgs, ... }: {
  imports = [
    ../modules/base.nix
    ../modules/boot.nix
    ../modules/fs.nix
    ../modules/networking.nix
    ../modules/nvidia.nix
    ../modules/secrets.nix
    ../modules/services.nix
  ];

  config = {
    # set filesystems mount
    fs.btrfs.device = "@data";
    fs.btrfs.volumes = {
      "/data" = [ "subvol=/" "rw" "relatime" "ssd" "space_cache=v2" ];
    };
    fs.normal.volumes = {
      "/" = {
        fsType = "ext4";
        device = "@";
        options = [ ];
      };
    };
    fs.swap.device = "@swap";
    fs.boot.device = "@boot";

    # hardware settings
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
    hardware.opengl.extraPackages = with pkgs; [
      libva
      vaapiVdpau
      libvdpau-va-gl
    ];

    hardware.cpu.amd.updateMicrocode = true;

    # additional system packages
    environment.systemPackages = with pkgs; [ glxinfo ];

    # gpu setting
    services.xserver.videoDrivers = [ "amdgpu" ];
    hardware.nvidia.prime = {
      amdgpuBusId = "PCI:6:0:0";

      nvidiaBusId = "PCI:1:0:0";
    };

    # networking related
    networking.firewall.allowedTCPPorts = [ 22 1443 ];
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --source 192.168.5.0/24 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 192.168.5.0/24 -j nixos-fw-accept
    '';

    # enable ddns
    services.cloudflare-ddns = {
      enable = true;
      domains = config.sops.secrets.cloudflare-ddns-domains.path;
      interface = "enp4s0";
      token = config.sops.secrets.cloudflare-token.path;
      zone-id = config.sops.secrets.cloudflare-zone-id.path;
    };

    # enable home-manager for users
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.mt = {
      imports = [ ../users/modules/shell.nix ];
      home.stateVersion = "23.05";
    };
  };
}