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

  config =
    let
      infra_node_ip = "192.168.128.4";
      infra_node_ip6 = "fd12:3456:789a:1::4";
      wan = "enp2s0";
    in
    {
      system.stateVersion = "23.05";
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

      # gpu setting
      services.xserver.videoDrivers = [ "i915" ];

      networking.useNetworkd = true;

      # networking related
      networking.firewall.allowedTCPPorts = [ 1443 6443 ];
      services.resolved.extraConfig = ''
                    DNSStubListener = false
              			LLMNR = false
              			MulticastDNS = false
        						DNSSEC = false
      '';

      # enable onedrive
      services.onedrive.enable = true;

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
      power.ups = {
        enable = true;
        mode = "netclient";
        upsmon = {
          monitor.mt = {
            user = "mt";
            system = "main@router.home.rmtt.host";
            passwordFile = config.sops.secrets.ups_pass.path;
          };
        };
      };

      networking.wireguard.networks = [
        {
          ip = [ "${infra_node_ip}/24" "${infra_node_ip6}/64" ];
          privateKeyFile = config.sops.secrets.wg-private.path;

          peers = [
            {
              allowedIPs = [ "0.0.0.0/0" "::/0" ];
              endpoint = "router.home.rmtt.host:51820";
              publicKey = "RYZS5mHgkmjW+/D40Zxn9d/h8NzvN4pzJVbnWK3DbXg=";
            }
          ];
        }
      ];

      services.rke2 = {
        enable = true;
        role = "server";

        configFile = config.sops.secrets.rke2.path;
        params = [
          "--node-ip=${infra_node_ip},${infra_node_ip6}"
        ];
      };
      # for port forward
      services.socat = {
        enable = true;
        listen = "TCP-LISTEN:1443";
        remote = "TCP:127.0.0.1:443";
      };

      networking.firewall.prerouting = true;
      networking.firewall.trustedSubnets = {
        ipv4 = [ "10.42.0.0/16" "10.43.0.0/16" ];
        ipv6 = [ "2001:cafe:42::/56" "2001:cafe:43::/112" ];
      };
      networking.interfaces."${wan}" = {
        wakeOnLan.enable = true;
        useDHCP = true;
      };
    };
}
