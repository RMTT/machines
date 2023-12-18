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
      listenPort = mkOption {
        type = int;
        default = 12345;
      };
      ip = mkOption {
        type = listOf str;
      };

      name = mkOption {
        type = nullOr str;
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
    let
      counter = { value = 0; };
      inc = self: { value = self.value + 1; };
    in
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

      systemd.network.networks = listToAttrs (lists.imap0
        (i: config:
          let name = if config.name == null then "wg${toString i}" else config.name;
          in
          {
            name = name;
            value = {
              matchConfig = { Name = name; };
							address = config.ip;
            };
          }
        )
        cfg.networks);
    };
}
