{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/secrets.nix
    ../modules/base.nix
    ../modules/fs.nix
    ../modules/networking.nix
    ../modules/services.nix
    ../modules/docker.nix
    ../modules/wireguard.nix
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

    sops.secrets.wg-private = {
      owner = "systemd-network";
      mode = "0400";
      sopsFile = ./keys/wg-private.key;
      format = "binary";
    };
    networking.wireguard.networks = [
      {
        ip = [ "172.31.1.4/24" ];
        privateKeyFile = config.sops.secrets.wg-private.path;

        peers = [
          {
            allowedIPs = [ "172.31.1.1/24" ];
            endpoint = "portal:30005";
            publicKey = "nzARKMdkzfy1lMN9xk10yiMfAMzB889NROSa5jvDUBo=";
          }
        ];
      }
    ];
  };
}
