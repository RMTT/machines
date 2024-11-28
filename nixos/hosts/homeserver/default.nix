{ config, pkgs, modules, lib, ... }: {
  imports = with modules; [
    base
    fs
    networking
    services
    docker
    globals
    godel
    gravity
    ./secrets
  ];

  config = let
    infra_node_ip = "192.168.128.4";
    wan = "enp2s0";
  in {
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
    networking.firewall.allowedTCPPorts = [ 1443 ];
    networking.firewall.trustedSubnets.ipv4 = [
      "10.42.0.0/16" # k8s pod
      "10.43.0.0/16" # k8s service
      "100.64.0.0/16" # tailscale
    ];

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
      mode = "netserver";
      ups.main = {
        driver = "usbhid-ups";
        port = "auto";
        directives = [
          "default.battery.charge.low = 20"
          "default.battery.runtime.low = 180"
        ];
      };

      upsmon = {
        monitor.mt = {
          user = "mt";
          system = "main@localhost";
          passwordFile = config.sops.secrets.ups_pass.path;
        };
      };

      users.mt = {
        upsmon = "primary";
        instcmds = [ "ALL" ];
        actions = [ "SET" ];
        passwordFile = config.sops.secrets.ups_pass.path;
      };

      upsd = {
        enable = true;
        listen = [{
          address = "0.0.0.0";
          port = 3493;
        }];
      };
    };

    services.k3s = {
      enable = true;
      configPath = ./config/k3s.yaml;
      role = "server";
    };
    services.godel = {
      enable = true;
      cert = ./secrets/homeserver.cert;
      privateKey = config.sops.secrets.godel-private.path;
      address = "${infra_node_ip}";
      remoteId = "cn2-la.infra.rmtt.host";
      remoteAddress = "cn2-la.rmtt.host";
      localAddress = "192.168.6.2";
    };

    services.gravity = {
      enable = true;
      ipsec = {
        enable = true;
        organization = "rmtt.tech";
        commonName = "homeserver";
        privateKey = config.sops.secrets.gravity-private.path;
        endpoints = [
          {
            serialNumber = "1";
            addressFamily = "ip4";
            address = "null";
          }
          {
            serialNumber = "0";
            addressFamily = "ip6";
            address = "null";
          }
        ];
      };
      reload = {
        enable = true;
        headerFile = config.sops.secrets.header.path;
      };

      strongswan = { interfaces = [ "enp2s0" ]; };
      address = [ "2a0c:b641:69c:5220::1/60" ];
      bird = {
        enable = true;
        prefix = "2a0c:b641:69c:5220::/60";
      };
      divi = {
        enable = true;
        prefix = "2a0c:b641:69c:5224:0:4::/96";
      };
    };
  };
}
