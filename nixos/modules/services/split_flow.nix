{ config, lib, pkgs, ownpkgs, ... }:
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
		networking.firewall.trustedInterfaces = [ "Meta" ];
		networking.firewall.extraCommands = "iptables -t mangle -I nixos-fw-rpfilter -i Meta -j RETURN";
    systemd.services.clash = {
      description = "clash service";
      path = with pkgs; [ cfg.package iptables bash iproute2 sysctl ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.service" ];
      script =
        "	ln -sfn ${cfg.ui} $STATE_DIRECTORY/ui\n	${cfg.package}/bin/clash-meta -d $STATE_DIRECTORY -f ${cfg.config}\n";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        LimitNPROC = 500;
        LimitNOFILE = 1000000;
        ExecStartPre =
          "${pkgs.bash}/bin/bash ${../scripts/clash-tproxy.sh} clean";
        ExecStopPost =
          "${pkgs.bash}/bin/bash ${../scripts/clash-tproxy.sh} clean";
        StateDirectory = "clash";
        StateDirectoryMode = "0750";
      };
    };

    systemd.services.adguardhome.serviceConfig.AmbientCapabilities =
      mkIf cfg.ad.enable [ "CAP_NET_RAW" ];
    services.adguardhome = mkIf cfg.ad.enable {
      enable = true;
      settings = { dhcp = cfg.ad.dhcp; };
    };

		systemd.services.china_list = {
			enable = true;
			description = "dnsmasq china list";
			path = with pkgs; [ wget ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.service" "clash.service" ];
			script = ''
				wget https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf -O $CONFIGURATION_DIRECTORY/google.conf
				wget https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf -O $CONFIGURATION_DIRECTORY/china.conf
				systemctl restart dnsmasq
				'';
			serviceConfig = {
				type = "oneshot";
				ConfigurationDirectory = "dnsmasq.china_list";
			};
		};

		systemd.timers.china_list_timer = {
			enable = true;
			wantedBy = [ "timers.target" ];
			timerConfig = {
				unit = "china_list.service";
				OnUnitActiveSec = "*-*-* 02:00:00";
			};
		};

		services.dnsmasq = {
			enable = true;
			settings = {
				port = 1153;
				no-resolv = true;
				strict-order = true;
				cache-size = 0;
				conf-dir = "/etc/dnsmasq.china_list";
				server = [ "127.0.0.1#1053" ];
			};
			resolveLocalQueries = false;
		};
		systemd.services.dnsmasq.after = [ "clash.service" ];
  };
}
