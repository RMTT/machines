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
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = cfg.config;
    };
  };
}
