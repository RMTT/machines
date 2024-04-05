{ pkgs, lib, modules, config, ... }:
with lib; {
  imports = with modules; [
    services
    base
    fs
    networking
    wireguard
    ./secrets.nix
  ];

  config =
    let
      lan = [ "enp1s0" "enp2s0" "enp3s0" ];
      wan = "enp4s0";

      lan_gateway = "192.168.6.1"; # for DHCP and nat
      lan_ip_prefix = 24;
      lan_ip_mask = "255.255.255.0";
      lan_ip_start = "192.168.6.10";
      lan_ip_end = "192.168.6.233";

      infra_node_ip = "192.168.128.3";
    in
    {
      system.stateVersion = "23.05";
      base.gl.enable = false;

      fs.normal.volumes = {
        "/" = {
          fsType = "ext4";
          label = "@";
          options =
            [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
        };
      };
      fs.boot.label = "@boot";

      hardware.cpu.intel.updateMicrocode = true;

      # disable docker
      virtualisation.docker.enable = mkForce false;

      boot.kernel.sysctl = {
        # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
        # By default, not automatically configure any IPv6 addresses.
        "net.ipv6.conf.all.accept_ra" = 0;
        "net.ipv6.conf.all.autoconf" = 0;
        "net.ipv6.conf.all.use_tempaddr" = 0;

        # On WAN, allow IPv6 autoconfiguration and tempory address use.
        "net.ipv6.conf.${wan}.accept_ra" = 2;
        "net.ipv6.conf.${wan}.autoconf" = 1;
      };

      networking.useNetworkd = true;
      networking.bridges = {
        lan = { interfaces = lan; };
        wan = { interfaces = [ wan ]; };
      };
      # bypass lan
      networking.firewall.trustedInterfaces = [ "lan" "tailscale0" ];
      systemd.network = {
        networks = {
          wan = {
            name = "wan";
            networkConfig = { DHCP = "yes"; };
            dhcpV6Config = { WithoutRA = "solicit"; };
            dhcpPrefixDelegationConfig = {
              UplinkInterface = ":self";
              SubnetId = 0;
              Announce = "no";
            };
          };
          lan = {
            name = "lan";
            networkConfig = {
              Address = "${lan_gateway}/${toString lan_ip_prefix}";
              ConfigureWithoutCarrier = true;
              IPv6AcceptRA = "no";
              IPv6SendRA = "yes";
              DHCPPrefixDelegation = "yes";
            };
            dhcpPrefixDelegationConfig = {
              UplinkInterface = "wan";
              SubnetId = 1;
              Announce = "yes";
            };
          };
        };
      };
      services.resolved.extraConfig = ''
              DNS = 127.0.0.1 ::1 223.5.5.5 223.6.6.6
              DNSStubListener = false
        			DNSSEC = false
      '';

      # enable nat from lan
      networking.nat = {
        enable = true;
        internalIPs = [
          "${lan_gateway}/${toString lan_ip_prefix}"
          "198.18.0.1/30" # clash tun ip
        ];
        externalInterface = "wan";
      };

      # enable clash and adguardhome (for DNS and DHCP)
      services.split_flow = {
        enable = true;
        config = config.sops.secrets.clash_config.path;

        ad = {
          enable = true;
          dhcp = {
            enabled = true;
            interface_name = "lan";
            dhcpv4 = {
              gateway_ip = lan_gateway;
              subnet_mask = lan_ip_mask;
              range_start = lan_ip_start;
              range_end = lan_ip_end;
            };
          };
        };
      };

      # wireguard and udp2raw
      services.udp2raw = {
        enable = true;
        localAddress = "127.0.0.1";
        openFirewall = false;
        remoteAddress = "103.39.79.110";
        role = "client";
        passwordFile = config.sops.secrets.udp2raw.path;
      };
      networking.wireguard.networks = [
        {
          ip = [ "${infra_node_ip}/24" ];
          privateKeyFile = config.sops.secrets.wg-private.path;

          peers = [
            {
              allowedIPs = [ "${infra_node_ip}/24" ];
              endpoint = "127.0.0.1:51821";
              publicKey = "2nzzD9C33j6loxVcrjfeWvokbUBXpyxEryUk6HN60nE=";
            }
            {
              allowedIPs = [ "192.168.128.4/32" ];
              publicKey = "CN+zErqQ3JIlksx51LgY6exZgjDNIGJih73KhO1WpkI=";
            }
          ];
        }
      ];

      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      networking.routeFromIpset = [
        {
          rule = {
            fwmark = "6";
          };
          name = "chnroute";

          ipset = {
            script = ''
              					wget https://raw.githubusercontent.com/fernvenue/chn-cidr-list/master/ipv4.txt -O $V4_FILE
              					wget https://raw.githubusercontent.com/fernvenue/chn-cidr-list/master/ipv6.txt -O $V6_FILE
            '';
          };
        }
      ];
    };
}
