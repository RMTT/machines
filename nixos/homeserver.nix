{ config, pkgs, ... }: {
  imports = [
    ./modules/secrets.nix
    ./modules/base.nix
    ./modules/fs.nix
    ./modules/networking.nix
    ./modules/nvidia.nix
    ./modules/services.nix
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

    hardware.cpu.amd.updateMicrocode = true;

		boot.kernel.sysctl = {
			"vm.overcommit_memory" = 1;
		};

    # additional system packages
    environment.systemPackages = with pkgs; [ glxinfo ];

    # gpu setting
    services.xserver.videoDrivers = [ "amdgpu" ];
    nvidia.usage = "full";

    # networking related
    networking.firewall.allowedTCPPorts = [ 22 1443 ];
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --source 192.168.6.0/24 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 192.168.6.0/24 -j nixos-fw-accept
    '';

    # enable ddns
    sops.secrets.cloudflare-ddns-domains = { };
    sops.secrets.cloudflare-zone-id = { };
    sops.secrets.cloudflare-token = { };
    services.cloudflare-ddns = {
      enable = true;
      domains = config.sops.secrets.cloudflare-ddns-domains.path;
      interface = "enp4s0";
      token = config.sops.secrets.cloudflare-token.path;
      zone-id = config.sops.secrets.cloudflare-zone-id.path;
    };

    # ssh disable password
    services.openssh.settings = { PasswordAuthentication = false; };

    # enable home-manager for users
    home-manager.users.mt = {
      imports = [ ../home/modules/shell.nix ];
      home.stateVersion = "23.05";
    };
  };
}
