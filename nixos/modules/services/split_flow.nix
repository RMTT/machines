{ config, lib, pkgs, ... }:
with lib;

let cfg = config.services.split_flow;
in {
  options = {
    services.split_flow = {
      enable =
        mkEnableOption "Clash service with adguardhome dns and dhcp server";

      config = mkOption {
        type = types.path;
        default = null;
        description = "clash config file path";
      };

      ui = mkOption {
        type = types.package;
        default = pkgs.ownpkgs.metacubexd;
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
    networking.firewall.trustedInterfaces = [ "Meta" ];
    networking.firewall.extraCommands =
      "iptables -t mangle -I nixos-fw-rpfilter -i Meta -j RETURN";
    systemd.services.clash = {
      description = "clash service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.service" ];
      script =
        "	ln -sfn ${cfg.ui}/public $STATE_DIRECTORY/ui\n	${pkgs.clash-meta}/bin/clash-meta -d $STATE_DIRECTORY -f ${cfg.config}\n";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        LimitNPROC = 500;
        LimitNOFILE = 1000000;
        StateDirectory = "clash";
        StateDirectoryMode = "0750";
      };
    };

    systemd.services.adguardhome.serviceConfig.AmbientCapabilities =
      mkIf cfg.ad.enable [ "CAP_NET_RAW" ];
    services.adguardhome = mkIf cfg.ad.enable {
      enable = true;
      settings = {
        dhcp = cfg.ad.dhcp;
        dns.upstream_dns = [ "127.0.0.1:1053" ];
      };
    };
  };
}
