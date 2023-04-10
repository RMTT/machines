{ config, lib, pkgs, pkgs-unstable, ... }:
with lib;
let cfg = config.services;
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

    # TODO: remove this when v2raya in stable
    services.v2raya = { enable = mkEnableOption "Cloudflare DDNS service"; };
  };

  config = {
    systemd.services.cloudflare-ddns = mkIf cfg.cloudflare-ddns.enable {
      description = "Update dns records to cloudflare";
      environment = {
        CLOUDFLARE_TOKEN = cfg.cloudflare-ddns.token;
        CLOUDFLARE_ZONE_ID = cfg.cloudflare-ddns.zone-id;
        CLOUDFLARE_DDNS_DOMAINS = cfg.cloudflare-ddns.domains;
        INTERFACE = cfg.cloudflare-ddns.interface;
      };
      path = with pkgs; [ bash gawk curl iproute2 ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ./scripts/cloudflare-ddns.sh;
      };
    };

    systemd.timers.cloudflare-ddns = mkIf cfg.cloudflare-ddns.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "10m";
        Unit = "cloudflare-ddns.service";
      };
    };

    systemd.services.v2raya = mkIf cfg.v2raya.enable (let
      nftablesEnabled = config.networking.nftables.enable;
      iptablesServices = [ "iptables.service" ]
        ++ optional config.networking.enableIPv6 "ip6tables.service";
      tableServices =
        if nftablesEnabled then [ "nftables.service" ] else iptablesServices;
    in {
      unitConfig = {
        Description = "v2rayA service";
        Documentation = "https://github.com/v2rayA/v2rayA/wiki";
        After = [ "network.target" "nss-lookup.target" ] ++ tableServices;
        Wants = [ "network.target" ];
      };

      serviceConfig = {
        User = "root";
        ExecStart = "${getExe pkgs-unstable.v2raya} --log-disable-timestamp";
        Environment = [ "V2RAYA_LOG_FILE=/var/log/v2raya/v2raya.log" ];
        LimitNPROC = 500;
        LimitNOFILE = 1000000;
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        iptables
        bash
        iproute2
      ]; # required by v2rayA TProxy functionality
    });
  };
}
