{ lib, config, pkgs, ... }:
let
  cfg = config.services.udp2raw;
in
with lib;{
  options = {
    services.udp2raw = {
      enable = mkEnableOption "Enable udp2raw service";
      package = mkOption {
        type = types.package;
        default = pkgs.ownpkgs.udp2raw-bin;
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
      };

      localAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
      };
      localPort = mkOption {
        type = types.int;
        default = 51821;
      };

      remoteAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      remotePort = mkOption {
        type = types.int;
        default = 51821;
      };

      role = mkOption {
        type = types.str;
        default = "server";
      };

      passwordFile = mkOption {
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.udp2raw =
      let
        execStr = "${cfg.package}/bin/udp2raw ${if cfg.role == "server" then "-s" else "-c"} -l ${cfg.localAddress}:${toString cfg.localPort} -r ${cfg.remoteAddress}:${toString cfg.remotePort}";
      in
      {
        enable = true;
        description = "udp2raw";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [ iptables bash ];

        preStart = "${execStr} --clear || true";
        postStop = "${execStr} --clear || true";
        script = ''
          								pass=$(<${cfg.passwordFile})
                    			${execStr} -k $pass -a --fix-gro'';
        serviceConfig = {
          Type = "exec";
        };
      };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.localPort ];
  };
}
