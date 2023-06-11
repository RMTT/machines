{ pkgs-unstable, lib, config, ... }:
with lib; {
  imports = [
    ./modules/secrets.nix
    ./modules/services.nix
    ./modules/base.nix
    ./modules/fs.nix
    ./modules/networking.nix
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
        device = "@";
        options = [ ];
      };
    };
    fs.boot.device = "@boot";

    hardware.cpu.intel.updateMicrocode = true;

    # disable network manager
    networking.networkmanager.enable = mkForce false;

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

    # disable dhcpcd in wan
    networking.interfaces."${wan}".useDHCP = false;

    # network interfaces
    networking.bridges = {
      # lan interfaces
      lan = {
        rstp = true;
        interfaces = lan;
      };
    };

    # bypass lan
    networking.firewall.trustedInterfaces = [ "lan" ];
    networking.interfaces.lan = {
      name = "lan";
      useDHCP = false;
      ipv4.addresses = [{
        address = lan_gateway;
        prefixLength = lan_ip_prefix;
      }];
    };

    # enable PPPoE
    sops.secrets.pppoe_auth = {
      sopsFile = ../secrets/pppoe_auth;
      format = "binary";
    };
    services.pppoe = {
      enable = true;
      ifname = "ppp0";
      wanName = wan;
      authFile = config.sops.secrets.pppoe_auth.path;
      ipv6RAIf = "lan";
    };

    # enable nat from lan
    networking.nat = {
      enable = true;
      internalIPs = [ "${lan_gateway}/${toString lan_ip_prefix}" ];
      externalInterface = "ppp0";
    };

    # enable clash and adguardhome (for DNS and DHCP)
    sops.secrets.clash_config = {
      sopsFile = ../secrets/clash_config;
      format = "binary";
      mode = "644";
    };
    services.clash = {
      enable = true;
      config = config.sops.secrets.clash_config.path;
			package = pkgs-unstable.clash-meta;

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
          dhcpv6 = {
            ra_allow_slaac = false;
            range_start = "2001::1";
          };
        };
      };
    };

  };
}
