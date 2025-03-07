{ lib, pkgs, config, ... }: with lib;
let
  cfg = config.services.gravity;
in
{
  options = {
    services.gravity.bird = {
      enable = mkEnableOption "bird integration";
      prefix = mkOption {
        type = types.str;
        description = "prefix to be announced for local node";
      };
    };
  };

  config = mkIf cfg.enable {
    services.bird = {
      enable = true;
      config = ''
        ipv6 sadr table sadr6;
        protocol device {
          scan time 5;
        }
        protocol kernel {
          kernel table ${toString cfg.table};
          ipv6 sadr {
            export all;
            import none;
					};
        }
				protocol kernel {
					ipv6 {
						export where proto = "announce";
						import none;
					};
				};
        protocol static announce {
					ipv6;
          route 2a0c:b641:69c::/48 via "gravity";
        }
        protocol static {
          ipv6 sadr;
          route ${cfg.bird.prefix} from ::/0 unreachable;
        }
        protocol babel {
          vrf "gravity";
          ipv6 sadr {
            export all;
            import all;
          };
          randomize router id;
          interface "gn*" {
            type tunnel;
            rxcost 32;
            hello interval 20 s;
            rtt cost 1024;
            rtt max 1024 ms;
            rx buffer 2000;
          };
        }
      '';
    };
  };
}
