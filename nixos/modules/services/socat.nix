{ lib, config, pkgs, ... }:
let
  cfg = config.services.socat;
in
with lib;{
  options = {
    services.socat = {
      enable = mkEnableOption "Enable socat service";

      listen = mkOption {
        type = types.str;
      };

      remote = mkOption {
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.socat =
      {
        enable = true;
        description = "socat";
        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [ socat ];

        script = "socat ${cfg.listen},fork,reuseaddr ${cfg.remote}";
        serviceConfig = {
          Type = "exec";
        };
      };
  };
}
