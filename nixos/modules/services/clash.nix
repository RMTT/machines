{ config, lib, pkgs, ownpkgs, ... }:
with lib;

let cfg = config.services.clash;
in {
  options = {
    services.clash = {
      enable =
        mkEnableOption "Clash service with adguardhome dns and dhcp server";

      config = mkOption {
        type = types.path;
        default = null;
        description = "clash config file path";
      };

      package = mkOption {
        type = types.package;
        default = ownpkgs.clash-premium;
      };

      ad = {
        enable = mkEnableOption "Enable AdGuardHome";

        dhcp = mkOption {
          type = types.attrs;
          default = { };
          description = "dhcp settings for adguardhome";
        };
      };
    };
  };

  config = {
    users.users.clash = mkIf cfg.enable {
      name = "clash";
      group = "clash";
      isSystemUser = true;
    };
    users.groups.clash = mkIf cfg.enable { };
    systemd.services.clash = mkIf cfg.enable {
      description = "clash service";
      path = with pkgs; [ cfg.package iptables bash iproute2 ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.service" ];
      serviceConfig = {
        Type = "simple";
        User = "clash";
        Group = "clash";
        Restart = "always";
        ExecStartPre =
          "${pkgs.bash}/bin/bash ${../scripts/clash-tproxy.sh} clean";
        ExecStart =
          "${cfg.package}/bin/clash -d $STATE_DIRECTORY -f ${cfg.config}";
        ExecStartPost =
          "${pkgs.bash}/bin/bash ${../scripts/clash-tproxy.sh} setup";
        ExecStopPost =
          "${pkgs.bash}/bin/bash ${../scripts/clash-tproxy.sh} clean";
        StateDirectory = "clash";
        StateDirectoryMode = "0750";
        CapabilityBoundingSet =
          [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
        AmbientCapabilities =
          [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
      };
    };

    systemd.services.adguardhome.serviceConfig.AmbientCapabilities =
      mkIf cfg.ad.enable [ "CAP_NET_RAW" ];
    services.adguardhome = mkIf cfg.ad.enable {
      enable = true;
      settings = {
        bind_port = 2048;
        dns = { port = 1053; };
        dhcp = cfg.ad.dhcp;
      };
    };
  };
}
