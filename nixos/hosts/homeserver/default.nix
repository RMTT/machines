{ config, pkgs, modules, lib, ... }: {
  imports = with modules; [
    base
    fs
    networking
    services
    docker
    wireguard
    ./secrets.nix
  ];

  config = with lib; {
    # set filesystems mount
    fs.btrfs.label = "@data";
    fs.btrfs.volumes = {
      "/data" = [ "subvol=/" "rw" "relatime" "ssd" "space_cache=v2" ];
    };
    fs.normal.volumes = {
      "/" = {
        fsType = "ext4";
        label = "@";
        options =
          [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
      };
    };
    fs.swap.label = "@swap";
    fs.boot.label = "@boot";

    hardware.cpu.intel.updateMicrocode = true;

    boot.kernel.sysctl = {
      "vm.overcommit_memory" = 1;
      "net.ipv6.route.max_size" = 409600;
    };

    virtualisation.docker.portainer.enable = true;

    # gpu setting
    services.xserver.videoDrivers = [ "i915" ];

    networking.useNetworkd = true;

    # networking related
    networking.firewall.allowedTCPPorts = [ 1443 ];
    services.resolved.extraConfig = ''
                  DNSStubListener = false
            			LLMNR = false
            			MulticastDNS = false
      						DNSSEC = false
    '';

    base.onedrive.enable = true;

    # set msmtp, for sending notification
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

    # ups
    users = {
      users.nut = {
        isSystemUser = true;
        group = "nut";
        home = "/var/lib/nut";
        createHome = true;
      };
      groups.nut = { };
    };
    power.ups = {
      enable = true;
      ups.main = {
        driver = "usbhid-ups";
        port = "auto";
      };
    };
    environment.etc = {
      "nut/upsd.conf".source = ./config/upsd.conf;
      "nut/upsd.users".source = ./config/upsd.users;
      "nut/upsmon.conf".source = pkgs.writeText "upsmon.conf" ''
        MONITOR main@localhost 1 upsuser upspass primary
        SHUTDOWNCMD "${pkgs.systemd}/bin/systemctl poweroff"
      '';
    };

    networking.wireguard.networks = [
      {
        ip = [ "192.168.128.4/24" ];
        privateKeyFile = config.sops.secrets.wg-private.path;

        peers = [
          {
            allowedIPs = [ "192.168.128.1/24" ];
            endpoint = "portal:30005";
            publicKey = "nzARKMdkzfy1lMN9xk10yiMfAMzB889NROSa5jvDUBo=";
          }
        ];
      }
    ];
  };
}
