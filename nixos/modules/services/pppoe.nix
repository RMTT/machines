{ lib, config, ... }:
with lib;
let cfg = config.services.pppoe;
in {
  options = {
    services.pppoe = {
      enable = mkEnableOption "Enable PPPoE, also start dhcpcd to get ipv6";

      ifname = mkOption {
        type = types.str;
        default = "ppp0";
        description = "interface name of PPPoE";
      };

      authFile = mkOption {
        type = types.path;
        default = null;
        description = "file contains username and password";
      };
    };
  };

  config = mkIf cfg.enable {
    services.pppd = {
      enable = true;
      peers.main = {
        enable = true;
        autostart = true;
        config = ''
                              plugin pppoe.so wan

                    					ifname ${cfg.ifname}

                    					file ${cfg.authFile}
                              defaultroute
                              noipdefault
          										persist
          										maxfail 0
          										holdoff 5

                    					+ipv6 ipv6cp-use-persistent
        '';
      };
    };
    systemd.network.networks = {
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
        routes = [{ Gateway = "::"; }];
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "ppp0";
          SubnetId = 0;
          Announce = "no";
        };
      };
    };
  };
}
