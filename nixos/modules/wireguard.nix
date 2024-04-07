{ lib, config, ... }: with lib;
let
  cfg = config.networking.wireguard;
  peerModule = with types; {
    options = {
      allowedIPs = mkOption {
        type = listOf str;
      };
      publicKey = mkOption {
        type = str;
      };

      endpoint = mkOption {
        type = nullOr str;
        default = null;
      };
    };
  };

  networkModule = with types;{
    options = {
      privateKeyFile = mkOption {
        type = path;
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
      };

      listenPort = mkOption {
        type = int;
        default = 51820;
      };
      ip = mkOption {
        type = listOf str;
      };

      mtu = mkOption {
        type = int;
        default = 1420;
      };

      name = mkOption {
        type = nullOr str;
        default = null;
      };

      script = mkOption {
        type = nullOr lines;
        default = null;
      };

      peers = mkOption {
        type = listOf (submodule peerModule);
      };
    };
  };
in
{
  options.networking.wireguard = {
    networks = mkOption {
      type = with types; listOf (submodule networkModule);
      default = [ ];
      example = [{
        ips = [ "172.31.1.1/24" ];
        privateKeyFile = "...";
        listenPort = 12345;
        peers = [
          {
            allowedIPs = [ ];
            PublicKey = "";
          }
        ];
      }];
    };
  };
  config =
    {
      systemd.network.netdevs = listToAttrs (lists.imap0
        (i: config:
          let name = if config.name == null then "wg${toString i}" else config.name;
          in
          {
            name = name;
            value = {
              netdevConfig = {
                Kind = "wireguard";
                Name = name;
              };
              wireguardConfig = {
                ListenPort = config.listenPort;
                PrivateKeyFile = config.privateKeyFile;
                RouteTable = "main";
              };
              wireguardPeers = map
                (peer: {
                  wireguardPeerConfig = {
                    AllowedIPs = peer.allowedIPs;
                    PersistentKeepalive = 15;
                    PublicKey = peer.publicKey;
                    Endpoint = mkIf (peer.endpoint != null) peer.endpoint;
                  };
                })
                config.peers;
            };
          })
        cfg.networks);

      systemd.services = listToAttrs (lists.imap0
        (i: config:
          let name = if config.name == null then "wg${toString i}" else config.name;
          in
          {
            name = "wg-script@${name}";
            value = {
              enable = true;
              wants = [ "sys-devices-virtual-net-${name}.device" ];
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                Type = "simple";
                KillMode = "mixed";
              };
              script = config.script;
              scriptArgs = "%i";
            };
          }
        )
        (filter (config: config.script != null) cfg.networks)
      );

      networking.firewall.allowedUDPPorts = map (config: config.listenPort)
        (filter (config: config.openFirewall) cfg.networks);

      systemd.network.networks = listToAttrs (lists.imap0
        (i: config:
          let name = if config.name == null then "wg${toString i}" else config.name;
          in
          {
            name = name;
            value = {
              matchConfig = { Name = name; };
              address = config.ip;
              linkConfig = {
                MTUBytes = toString config.mtu;
              };
            };
          }
        )
        cfg.networks);

    };
}
