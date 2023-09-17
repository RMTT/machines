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

  config = {
    services.pppd = mkIf cfg.enable {
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
  };
}
