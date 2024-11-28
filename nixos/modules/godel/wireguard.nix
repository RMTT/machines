{ pkgs, config, lib, ... }:
let
  cfg = config.services.godel;
  registry = import ./registry.nix;
in {
  imports = [ ../services/udp2raw.nix ];
  options = with lib; {
    services.godel = {
      enable = mkEnableOption "Enable godel module";
      address = mkOption { type = types.str; };
      privateKey = mkOption { type = types.path; };
      fakeTCP = mkEnableOption "use faketcp";
    };
  };
  config = lib.mkIf cfg.enable (let
    containEndpoint = peerConfig:
      (builtins.hasAttr "endpoint" peerConfig) && (peerConfig.endpoint != "");

    haveEndpoint_ = lib.lists.forEach registry (peerConfig:
      if config.networking.hostName == peerConfig.hostname then
        containEndpoint peerConfig
      else
        false);

    haveEndpoint = builtins.elem true haveEndpoint_;

    parsePeer = peerConfig:
      if config.networking.hostName != peerConfig.hostname
      && (haveEndpoint || containEndpoint peerConfig) then ''
        [Peer]
        PublicKey = ${peerConfig.publicKey}
        AllowedIPs = ${lib.concatStringsSep "," peerConfig.allowedIPs}
        ${if (containEndpoint peerConfig) then
          "Endpoint=${peerConfig.endpoint}"
        else
          ""}
      '' else
        "";
  in {
    boot.kernelModules = [ "wireguard" ];
    environment.systemPackages = with pkgs; [ wireguard-tools ];
    networking.firewall.trustedInterfaces = [ "godel" ];
    networking.firewall.allowedUDPPorts = [ 51820 ];

    environment.etc = {
      "wireguard/godel.conf" = {
        source = (pkgs.writeText "godel" ''
          [Interface]
          Address=${cfg.address}
          ListenPort = 51820
          PostUp = wg set %i private-key ${cfg.privateKey}

          ${lib.concatMapStrings parsePeer registry}
        '');
        mode = "0440";
      };
    };

    systemd.services.godel = {
      path = with pkgs; [ wireguard-tools ];
      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };
      script = "wg-quick up godel";
      preStop = "wg-quick down godel";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      reloadTriggers = [ config.environment.etc."wireguard/godel.conf".source ];
    };

    services.udp2raw = {
      enable = true;
      extraArgs = "--raw-mode faketcp";
    };
  });
}
