{ config, lib, ... }:
let
  cfg = config.virtualisation.docker;
  portainerYml = ./config/portainer.yml;
in with lib; {
  options = {
    # when launch portainer, you need specify a data dir to create a common volume
    virtualisation.docker.portainer = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      docker_data_path = mkOption {
        type = types.str;
        default = "/opt/docker_data";
      };
    };

    virtualisation.docker.listenTcp = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      tls = mkOption {
        type = types.bool;
        default = false;
      };
      tlscacert = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
      tlskey = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
      tlscert = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
    };
  };

  config = {
    assertions = [
      (mkIf (cfg.listenTcp.enable && cfg.listenTcp.tls) {
        assertion = !(cfg.listenTcp.tlskey == null || cfg.listenTcp.tlscert
          == null || cfg.listenTcp.tlskey == null);
        message =
          "must specify tlscacert,tlscert,tlskey when use docker listen tcp";
      })
    ];
    # enable docker
    virtualisation.docker.enable = true;

    virtualisation.docker.daemon.settings = {
      # TODO: remove this when docker support nftables offically
      iptables = false; # docker will bypass nftables's input rule now
    } // (if cfg.listenTcp.enable && cfg.listenTcp.tls then {
      tls = true;
      tlsverify = true;
      tlscacert = cfg.listenTcp.tlscacert;
      tlscert = cfg.listenTcp.tlscert;
      tlskey = cfg.listenTcp.tlskey;
      hosts = [ "tcp://0.0.0.0:2376" ];
    } else
      mkIf cfg.listenTcp.enable { hosts = [ "tcp://0.0.0.0:2376" ]; });

    systemd.services.portainer = mkIf cfg.portainer.enable {
      enable = true;
      environment = { DOCKER_DATA_PATH = "${cfg.portainer.docker_data_path}"; };
      path = [ cfg.package ];
      script = ''
        docker compose -f ${portainerYml} up
      '';
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" "docker.socket" ];
    };
  };
}
