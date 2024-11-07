{ lib, pkgs, config, ... }: with lib;
let
  cfg = config.services.gravity.divi;
in
{
  options = {
    services.gravity = {
      divi = {
        enable = mkEnableOption "sample divi configuration";
        prefix = mkOption {
          type = types.str;
          description = "prefix to be announced for nat64";
        };
        dynamic-pool = mkOption {
          type = types.str;
          default = "10.200.0.0/16";
          description = "prefix for dynamic assignment";
        };
        oif = mkOption {
          type = types.str;
          default = "ens3";
          description = "name of ipv4 outbound interface";
        };
        allow = mkOption {
          default = [ "2a0c:b641:69c::/48" ];
          type = types.listOf types.str;
          description = "list of addresses allowed to use divi";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.network.networks.divi = {
      name = "divi";
      linkConfig = {
        MTUBytes = "1400";
      };
      routes = [
        {
          Destination = cfg.prefix;
          Table = config.services.gravity.table;
        }
        { Destination = cfg.dynamic-pool; }
      ];
      networkConfig.LinkLocalAddressing = false;
      linkConfig.RequiredForOnline = false;
    };

    systemd.services.divi = {
      serviceConfig = {
        ExecStart = "${pkgs.tayga}/bin/tayga -d --config ${pkgs.writeText "tayga.conf" ''
            tun-device divi
            ipv4-addr 10.200.0.1
            prefix ${cfg.prefix}
            dynamic-pool ${cfg.dynamic-pool}
          ''}";
      };
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    networking.nftables = {
      enable = true;
      tables = {
        filter4 = {
          name = "filter";
          family = "inet";
          content = ''
            chain forward {
              type filter hook forward priority 0;
              tcp flags syn tcp option maxseg size set 1200
            }
          '';
        };
        filter6 = {
          name = "filter";
          family = "ip6";
          content = ''
            chain forward {
              type filter hook forward priority 0;
              oifname "divi" ip6 saddr != { ${lib.concatStringsSep ", " cfg.allow} } reject
            }
          '';
        };
        nat = {
          family = "ip";
          content = ''
            chain postrouting {
              type nat hook postrouting priority 100;
              oifname "${cfg.oif}" ip saddr ${cfg.dynamic-pool} masquerade
            }
          '';
        };
      };
    };
  };
}
