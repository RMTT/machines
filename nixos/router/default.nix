{ pkgs, lib, config, ... }:
with lib; {
  imports = [
    ../modules/secrets.nix
    ../modules/services.nix
    ../modules/base.nix
    ../modules/fs.nix
    ../modules/networking.nix
  ];

  config = let
    lan = [ "enp1s0" "enp2s0" "enp3s0" ];
    wan = "enp4s0";

    lan_gateway = "192.168.6.1"; # for DHCP and nat
    lan_ip_prefix = 24;
    lan_ip_mask = "255.255.255.0";
    lan_ip_start = "192.168.6.10";
    lan_ip_end = "192.168.6.233";
  in {
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
      # if you use ipv4, this is all you need
      "net.ipv4.conf.all.forwarding" = true;

      # If you want to use it for ipv6
      "net.ipv6.conf.all.forwarding" = true;

      # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
      # By default, not automatically configure any IPv6 addresses.
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;

      # On WAN, allow IPv6 autoconfiguration and tempory address use.
      "net.ipv6.conf.${wan}.accept_ra" = 2;
      "net.ipv6.conf.${wan}.autoconf" = 1;
    };

    # enable PPPoE
    sops.secrets.pppoe_auth = {
      sopsFile = ../../secrets/pppoe_auth;
      format = "binary";
    };
    services.pppoe = {
      enable = true;
      ifname = "ppp0";
      authFile = config.sops.secrets.pppoe_auth.path;
    };

    networking.useNetworkd = true;
    networking.bridges = {
      lan = { interfaces = lan; };
      wan = { interfaces = [ wan ]; };
    };
    # bypass lan
    networking.firewall.trustedInterfaces = [ "lan" ];
    systemd.network = {
      networks = {
        wan = {
          name = "wan";
          networkConfig = { DHCP = "no"; };
        };
        lan = {
          name = "lan";
          networkConfig = {
            Address = "${lan_gateway}/${toString lan_ip_prefix}";
            LinkLocalAddressing = "ipv6";
            IPv6AcceptRA = "no";
            IPv6SendRA = "yes";
            DHCPPrefixDelegation = "yes";
          };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = "ppp0";
            SubnetId = 1;
            Announce = "yes";
          };
        };
        ppp0 = {
          name = "ppp0";
          networkConfig = {
            DHCP = "ipv6";
            IPv6AcceptRA = "no";
            DHCPPrefixDelegation = "yes";
          };
          dhcpV6Config = {
            WithoutRA = "solicit";
            UseDNS = false;
          };
          routes = [{ routeConfig = { Gateway = "::"; }; }];
          dhcpPrefixDelegationConfig = {
            UplinkInterface = "ppp0";
            SubnetId = 0;
            Announce = "no";
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
      internalIPs = [ "${lan_gateway}/${toString lan_ip_prefix}" ];
      externalInterface = "ppp0";
    };

    # enable clash and adguardhome (for DNS and DHCP)
    sops.secrets.clash_config = {
      sopsFile = ../../secrets/clash_config;
      format = "binary";
      mode = "644";
    };
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
    sops.secrets.wg-private = {
      owner = "systemd-network";
      mode = "0400";
      sopsFile = ./keys/wg-private.key;
      format = "binary";
    };

    systemd.network.netdevs."wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        ListenPort = 12345;
        PrivateKeyFile = config.sops.secrets.wg-private.path;
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          AllowedIPs = [ "172.31.1.0/24" ];
          Endpoint = "portal:30005";
          PersistentKeepalive = 15;
          PublicKey = "nzARKMdkzfy1lMN9xk10yiMfAMzB889NROSa5jvDUBo=";
        };
      }];
    };
    systemd.network.networks."wg0" = {
      matchConfig = { Name = "wg0"; };
      networkConfig = { Address = "172.31.1.3/24"; };
    };

    networking.nftables.ruleset =
      "	table ip nixos-nat {\n		chain post {\n			ip saddr != 172.31.1.0/24 oifname \"wg0\" masquerade\n		}\n	}\n";
    networking.firewall.allowedUDPPorts = [ 12345 ];
  };
}
