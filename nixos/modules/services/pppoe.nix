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

      wanName = mkOption {
        type = types.str;
        description = "wan interface name";
      };

      ipv6RAIf = mkOption {
        type = types.str;
        description = "interface for egress ipv6 RA messages";
      };
    };
  };

  config = {
    services.radvd = mkIf cfg.enable {
      enable = true;
      config = ''
                interface ${cfg.ipv6RAIf} {
                	AdvSendAdvert on;
                	MinRtrAdvInterval 3;
                	MaxRtrAdvInterval 10;

        					RDNSS 2400:3200::1 2400:3200:baba::1 {
        					};

                	AdvOtherConfigFlag on;
                	AdvManagedFlag off;
                	prefix ::/64 {
                		AdvOnLink on;
                		AdvAutonomous on;
                	};
                };
      '';
    };

    services.pppd = mkIf cfg.enable {
      enable = true;
      peers.main = {
        enable = true;
        autostart = true;
        config = ''
                    plugin pppoe.so ${cfg.wanName}

          					ifname ${cfg.ifname}

          					file ${cfg.authFile}
                    defaultroute
                    noipdefault
                    nodetach
                    noaccomp
                    nodeflate
                    nopcomp
                    novj
                    novjccomp

          					+ipv6 ipv6cp-use-persistent
        '';
      };
    };

    # using dhcpcd get ipv6
    networking.dhcpcd = mkIf cfg.enable {
      enable = true;
      persistent = true;
      allowInterfaces = [ cfg.ifname ];
      extraConfig = ''
        				nohook resolv.conf

                # generate a RFC 4361 complient DHCP ID
                duid

                # We don't want to expose our hw addr from the router to the internet,
                # so we generate a RFC7217 address.
                slaac private

                # we only want to handle IPv6 with dhcpcd, the IPv4 is still done
                # through pppd daemon
                noipv6rs
                ipv6only

                # settings for the interface
                interface ${cfg.ifname}
        					ipv6rs              # router advertisement solicitaion
        					iaid 1              # interface association ID
        					ia_pd 1 lan/0/60		 # request a PD and assign to interface
                				'';
    };
  };
}
