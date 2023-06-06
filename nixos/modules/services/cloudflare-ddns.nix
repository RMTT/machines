{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.cloudflare-ddns;
in {
  options = {
    services.cloudflare-ddns = {
      enable = mkEnableOption "Cloudflare DDNS service";

      domains = mkOption {
        type = types.str;
        description = "domains need update dns records, use shell array";
      };

      interface = mkOption {
        type = types.str;
        description = "net interface name";
      };

      token = mkOption {
        type = types.str;
        description = "cloudflare token";
      };

      zone-id = mkOption {
        type = types.str;
        description = "cloudflare zone id";
      };
    };
  };

  config = {
    systemd.services.cloudflare-ddns = mkIf cfg.enable {
      description = "Update dns records to cloudflare";
      environment = {
        CLOUDFLARE_TOKEN = cfg.token;
        CLOUDFLARE_ZONE_ID = cfg.zone-id;
        CLOUDFLARE_DDNS_DOMAINS = cfg.domains;
        INTERFACE = cfg.interface;
      };
      path = with pkgs; [ bash gawk curl iproute2 ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ../scripts/cloudflare-ddns.sh;
      };
    };

    systemd.timers.cloudflare-ddns = mkIf cfg.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "10m";
        Unit = "cloudflare-ddns.service";
      };
    };
  };
}
