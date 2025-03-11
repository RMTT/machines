{ pkgs, config, lib, ... }:
with lib;
let cfg = config.services.godel.k3s;
in {
  options = {
    services.godel.k3s = {
      enable = mkEnableOption "enable k3s";
      node-ip = mkOption { type = types.str; };
      role = mkOption { type = types.str; };
      node-labels = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };

  };

  imports = [ ./aronet.nix ./secrets.nix ];

  config = let
    k3s-config = if (cfg.role == "agent") then {
      server = "https://homeserver.infra.rmtt.host:6443";
      node-label = cfg.node-labels;
    } else {
      write-kubeconfig-mode = "0644";
      tls-san = [ "homeserver.infra.rmtt.host" ];
      node-label = cfg.node-labels;
      cluster-init = true;
    };

    # only use flannel to allocate ip for pods, inter-nodes routing via godel
    flannel-config = {
      Network = "10.42.0.0/16";
      EnableIPv6 = false;
      EnableIPv4 = true;
      IPv6Network = "::/0";
      Backend = { Type = "extension"; };
    };

    yaml = pkgs.formats.yaml { };
    json = pkgs.formats.json { };
  in mkIf cfg.enable {
    services.k3s = {
      enable = true;
      configPath = (yaml.generate "k3s-config" k3s-config);
      role = cfg.role;
      extraFlags = (if (cfg.role == "agent") then
        [ "--token-file ${config.sops.secrets.k3s-token.path}" ]
      else
        [ ]) ++ [
          "--node-ip ${cfg.node-ip}"
          "--node-external-ip ${cfg.node-ip}"
          "--flannel-conf ${json.generate "flannel-config" flannel-config}"
        ];
    };

    systemd.services.k3s.path = with pkgs; [ nftables ];
    systemd.services.k3s.after = [ "aronet.service" ];
    networking.firewall.trustedSubnets.ipv4 = [
      # need pass pod id to let pod access api server which listend on the node-ip
      "10.42.0.0/16" # pod ip range
    ];
  };
}
