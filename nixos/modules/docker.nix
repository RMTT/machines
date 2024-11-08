{ config, lib, ... }:
let
  cfg = config.virtualisation.docker;
  portainerYml = ./config/portainer.yml;
in
with lib; {
  options = {
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

    virtualisation.docker.daemon.settings = mkMerge [
      (mkIf cfg.listenTcp.enable { hosts = [ "tcp://0.0.0.0:2376" ]; })

      (mkIf (cfg.listenTcp.enable && cfg.listenTcp.tls) {
        tls = true;
        tlsverify = true;
        tlscacert = cfg.listenTcp.tlscacert;
        tlscert = cfg.listenTcp.tlscert;
        tlskey = cfg.listenTcp.tlskey;
      })
    ];
  };
}
