{ lib, config, pkgs, ... }: with lib;
let
  cfg = config.services.derper;
in
{
  options = {
    services.derper = {
      enable = mkEnableOption "Enable derper service";
      hostname = mkOption {
        type = types.str;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.ownpkgs.derper;
      };
      listen = mkOption {
        type = types.str;
        default = ":1443";
      };
      openFirewall = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = {
    systemd.services.derper = mkIf cfg.enable {
      enable = true;
      description = "tailscale derper server";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      script = "${cfg.package}/bin/derper -c /etc/derper/config -a ${cfg.listen} -hostname ${cfg.hostname} -certdir /etc/derper/certs";
    };


    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 1443 ];
      allowedUDPPorts = [ 3478 ];
    };
  };
}
