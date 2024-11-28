{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.gravity;
in {
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
    environment.systemPackages = [
      (pkgs.writers.writeBashBin "gravity" ''
        ${pkgs.strongswan}/sbin/swanctl $@ -u unix:///var/run/gravity.vici
      '')
    ];
    systemd.services.strongswan-gravity = {
      description = "strongSwan IPsec IKEv1/IKEv2 daemon using swanctl";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = with pkgs; [ kmod iproute2 iptables util-linux ];
      environment = {
        STRONGSWAN_CONF = pkgs.writeTextFile {
          name = "strongswan.conf";
          text = ''
            charon {
              interfaces_use = ${
                lib.strings.concatStringsSep "," cfg.strongswan.interfaces
              }
              port = 0
              port_nat_t = ${toString cfg.strongswan.port-nat-t}
              retransmit_timeout = 30
              retransmit_base = 1
              plugins {
                vici {
                  socket = "unix:///var/run/gravity.vici"
                }
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
        SWANCTL_DIR = "/etc/swanctl-gravity";
      };
      serviceConfig = {
        ExecStart = "${pkgs.strongswan}/sbin/charon-systemd";
        Type = "notify";
        Restart = "on-abnormal";
      };
    };
  };
}
