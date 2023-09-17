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
        default = pkgs.clash;
      };

      ui = mkOption {
        type = types.package;
        default = ownpkgs.yacd-meta;
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

  config = mkIf cfg.enable {
    users.users.clash = {
      name = "clash";
      group = "clash";
      isSystemUser = true;
    };
    users.groups.clash = { };
    systemd.services.clash = {
      description = "clash service";
      path = with pkgs; [ cfg.package iptables bash iproute2 sysctl ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.service" "adguardhome.service" ];
      script =
        "	ln -sfn ${cfg.ui} $STATE_DIRECTORY/ui\n	${cfg.package}/bin/clash-meta -d $STATE_DIRECTORY -f ${cfg.config}\n";
      serviceConfig = {
        Type = "simple";
        User = "clash";
        Group = "clash";
        Restart = "always";
        LimitNPROC = 500;
        LimitNOFILE = 1000000;
        ExecStartPre =
          "${pkgs.bash}/bin/bash ${../scripts/clash-tproxy.sh} clean";
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
      settings = { dhcp = cfg.ad.dhcp; };
    };

  };
}
