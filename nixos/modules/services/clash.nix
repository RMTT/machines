{ config, lib, pkgs, ... }:
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
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [ "Meta" ];
    systemd.services.clash = {
      description = "clash service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "NetworkManager.service" "systemd-networkd.service" "iwd.service" ];
      script =
        "${pkgs.clash-meta}/bin/clash-meta -d $STATE_DIRECTORY -f ${cfg.config}";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        LimitNPROC = 500;
        LimitNOFILE = 1000000;
        StateDirectory = "clash";
        StateDirectoryMode = "0750";
      };
    };
  };
}
