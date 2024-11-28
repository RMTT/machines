/* strongswan has some defects, and it's hard to use strongswan to build a reliable NAT Traversal tunnel.

   For example, we have host A behind NAT, host B with public ip: A <--...--> IPS router <--...--> B
   Now we create a ipsec tunnel between A and B via strongswan, and following situations will break this tunnel:
   1. A's port mapping changed: although A will constantly send keepalives to B, but B doesn't update A's ip and port via keepalives packets, so B will disconnect from A until A send ESP packets to B.
   2. because above problem A, when B require rekeying, B will give up this connection after 5 retries.
*/
{ lib, config, pkgs, ... }:
with lib;
let cfg = config.services.godel;
in {
  options = {
    services.godel = {
      enable = mkEnableOption "enable kuber service";
      internet = mkEnableOption "does machine have public ip?";
      cert = mkOption { type = types.path; };
      privateKey = mkOption { type = types.path; };
      remoteId = mkOption { type = types.string; };
      remoteAddress = mkOption {
        type = types.str;
        default = "";
      };
      localAddress = mkOption {
        type = types.str;
        default = config.services.godel.address;
      };
      address = mkOption {
        type = types.str;
        description = "ip v4 address for infra network";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [ "godel" ];
    networking.firewall.allowedUDPPorts = [ 500 4500 ];
    systemd.network.netdevs.godel = {
      netdevConfig = {
        Kind = "xfrm";
        Name = "godel";
        MTUBytes = 1400;
      };
      xfrmConfig = {
        InterfaceId = 123454321;
        Independent = true;
      };
    };
    systemd.network.networks.godel = {
      name = "godel";
      networkConfig = {
        Address = [ "${cfg.address}/24" ];
        ConfigureWithoutCarrier = true;
        IgnoreCarrierLoss = true;
        Description = "rmt's infra network";
      };
    };

    environment.etc = {
      "swanctl/x509ca/godel" = {
        source = ./ca.cert;
        mode = "0440";
      };
      "swanctl/x509/godel" = {
        source = cfg.cert;
        mode = "0440";
      };
      "swanctl/private/godel" = {
        source = cfg.privateKey;
        mode = "0440";
      };
    };
    environment.systemPackages = with pkgs; [ strongswan ];
    services.strongswan-swanctl = {
      enable = true;
      swanctl = {
        authorities.default.cacert = "godel";
        connections = {
          main = {
            rekey_time = mkIf cfg.internet "0";
            remote_addrs =
              mkIf (cfg.remoteAddress != "") [ "${cfg.remoteAddress}" ];
            local_addrs =
              mkIf (cfg.remoteAddress != "") [ "${cfg.localAddress}" ];
            remote.default = {
              auth = "pubkey";
              id = "CN=${cfg.remoteId}";
            };
            local.default = {
              auth = "pubkey";
              certs = [ "godel" ];
            };
            children.default = {
              rekey_time = mkIf cfg.internet "0";
              if_id_out = toString
                config.systemd.network.netdevs.godel.xfrmConfig.InterfaceId;
              if_id_in = toString
                config.systemd.network.netdevs.godel.xfrmConfig.InterfaceId;
              local_ts = [ "0.0.0.0/0" ];
              remote_ts = [ "0.0.0.0/0" ];
              start_action = "start";
              close_action = "start";
            };
          };
        };
      };
    };
  };
}
