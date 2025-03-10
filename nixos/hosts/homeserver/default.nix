{ config, pkgs, modules, lib, ... }: {
  imports = with modules; [
    base
    fs
    networking
    services
    globals
    godel
    gravity
    ./secrets
  ];

  config = let
    infra_node_ip = "192.168.128.4";
    infra_network = "fd97:1208:0:1::1/64";
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
          tls_starttls = true;
          from = "notification@rmtt.tech";
          host = "smtp.mail.me.com";
          port = 587;
          user = "mt@rmtt.tech";
          passwordeval =
            "${pkgs.coreutils}/bin/cat ${config.sops.secrets.smtp-pass.path}";
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
        sender = "notification@rmtt.tech";
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

    services.godel = {
      enable = true;
      network = infra_network;
      prefixs = [ "${infra_node_ip}/32" "10.42.0.0/24" ];
      extra_ip = [ "${infra_node_ip}/32" ];
      netns = true;
      k3s = {
        enable = true;
        node-ip = infra_node_ip;
        node-labels = [ "intel.feature.node.kubernetes.io/gpu=true" ];
        role = "server";
      };
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

      strongswan = { interfaces = [ "${wan}" ]; };
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
