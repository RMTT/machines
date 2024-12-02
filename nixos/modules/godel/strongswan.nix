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
      interface = mkOption {
        type = types.str;
        description = "the interface strongswan will listen";
      };
      remoteId = mkOption { type = types.string; };
      remoteAddress = mkOption {
        type = types.str;
        default = "";
      };
      address = mkOption {
        type = types.str;
        description = "ip v4 address for infra network";
      };
      routes = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [ "godel" ];
    networking.firewall.allowedUDPPorts = [ 12345 ];
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
      routes = builtins.map (dest: { Destination = dest; }) cfg.routes;
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
      strongswan.extraConfig = ''
        charon {
          interfaces_use = ${cfg.interface}
          port_nat_t = 12345
          port = 0
          retransmit_timeout = 30
          retransmit_base = 1
        }
      '';
      swanctl = {
        authorities.default.cacert = "godel";
        connections = {
          main = {
            rekey_time = mkIf cfg.internet "0";
            keyingtries = 0;
            local_port = 12345;
            remote_port = 12345;
            remote_addrs =
              mkIf (cfg.remoteAddress != "") [ "${cfg.remoteAddress}" ];
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
              start_action = "trap";
              close_action = "trap";
              dpd_action = "restart";
            };
          };
        };
      };
    };
  };
}
