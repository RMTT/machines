{ config, pkgs, lib, ... }: {
  imports = [
    ./modules/secrets.nix
    ./modules/base.nix
    ./modules/fs.nix
    ./modules/networking.nix
    ./modules/services.nix
  ];

  config = with lib; {
    # set filesystems mount
    fs.btrfs.device = "@data";
    fs.btrfs.volumes = {
      "/data" = [ "subvol=/" "rw" "relatime" "ssd" "space_cache=v2" ];
    };
    fs.normal.volumes = {
      "/" = {
        fsType = "ext4";
        device = "@";
        options =
          [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
      };
    };
    fs.swap.device = "@swap";
    fs.boot.device = "@boot";

    hardware.cpu.intel.updateMicrocode = true;

    boot.kernel.sysctl = {
      "vm.overcommit_memory" = 1;
      "net.ipv6.route.max_size" = 409600;
    };

    # additional system packages
    environment.systemPackages = with pkgs; [ glxinfo ];

    # gpu setting
    services.xserver.videoDrivers = [ "i915" ];

    # disable network manager
    networking.networkmanager.enable = mkForce false;

    # disable dhcpcd
    networking.useDHCP = false;

    # networking related
    networking.firewall.allowedTCPPorts = [ 22 1443 ];
    # allow lan
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --source 192.168.6.0/24 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 192.168.6.0/24 -j nixos-fw-accept
    '';

    security.polkit.enable = true;
    systemd.network.enable = true;
    systemd.network.networks.wan = {
      matchConfig.Name = "enp2s0";
      networkConfig.DHCP = "yes";
      dhcpV4Config = {
        UseDNS = true;
        UseRoutes = true;
      };
    };
    services.resolved.extraConfig = ''
                  DNSStubListener = false
            			LLMNR = false
            			MulticastDNS = false
      						DNSSEC = false
    '';

    # ssh disable password
    services.openssh.settings = { PasswordAuthentication = false; };

    base.onedrive.enable = true;

    # set msmtp, for sending notification
    sops.secrets.zoho-pass = { mode = "644"; };
    programs.msmtp = {
      enable = true;
      accounts = {
        default = {
          auth = true;
          tls = true;
          tls_starttls = false;
          from = "notify@rmtt.tech";
          host = "smtppro.zoho.com";
          port = 465;
          user = "d.rong@outlook.com";
          passwordeval =
            "${pkgs.coreutils}/bin/cat ${config.sops.secrets.zoho-pass.path}";
        };
      };
    };

    # config smartd, monitor disk status
    services.smartd = {
      enable = true;
      notifications.test = true;
      notifications.mail = {
        enable = true;
        recipient = "d.rong@outlook.com";
        sender = "notify@rmtt.tech";
      };
    };
  };
}
