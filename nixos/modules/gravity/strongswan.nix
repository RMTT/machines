{ lib, pkgs, config, ... }: with lib; let
  cfg = config.services.gravity;
in
{
  options = {
    services.gravity.strongswan = {
      port-nat-t = mkOption {
        type = types.port;
        default = 13000;
      };

      interfaces = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    services.strongswan-swanctl = {
      enable = true;

      strongswan.extraConfig = ''
        charon {
          interfaces_use = ${lib.strings.concatStringsSep "," cfg.strongswan.interfaces}
          port = 0
          port_nat_t = ${toString cfg.strongswan.port-nat-t}
          retransmit_timeout = 30
          retransmit_base = 1
          plugins {
            socket-default {
              set_source = yes
              set_sourceif = yes
            }
            dhcp {
              load = no
            }
          }
        }
        charon-systemd {
          journal {
            default = -1
            ike = 0
          }
        }
      '';
    };
  };
}
