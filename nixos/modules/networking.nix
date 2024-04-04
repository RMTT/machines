{ lib, config, pkgs, ... }:
let
  defaltLocalSubnet4 = "192.168.6.1/24";
  wgSubnet4 = [ "192.168.128.0/24" ];
  cfg = config.networking;
  hosts_internet = ''
        				85.237.205.152 portal-origin
            		101.227.98.233 portal
            		103.39.79.110 vps-hk

    						192.168.128.1 portal.infra.rmtt.host
    						192.168.128.2 vps-hk.infra.rmtt.host
    						192.168.128.3 router.infra.rmtt.host
    						192.168.128.4 homeserver.infra.rmtt.host
  '';
in
with lib; {
  options = {
    networking.bypassSubnet4 = mkOption {
      type = types.listOf types.str;
      default = [ "${defaltLocalSubnet4}" ] ++ wgSubnet4;
    };
  };

  config =
    let subnet4 = builtins.concatStringsSep "," cfg.bypassSubnet4;
    in {
      systemd.network = mkIf cfg.useNetworkd {
        enable = true;
        config = {
          networkConfig = {
            ManageForeignRoutingPolicyRules = false;
          };
        };

        wait-online.anyInterface = true;
        networks = mkIf cfg.useNetworkd {
          "dhcp" = {
            matchConfig = {
              Name = "en*";
              Type = "ether";
            };
            networkConfig = { DHCP = "yes"; };
          };
        };

      };

      networking.extraHosts = "	${hosts_internet}\n";

      networking.nftables = {
        enable = true;
        flushRuleset = false;
      };
      networking.useDHCP = false;
      networking.firewall = {
        enable = true;
        checkReversePath = "loose";
        logRefusedConnections = false;
        logRefusedUnicastsOnly = false;
        extraInputRules = "ip saddr {${subnet4}} accept";

        allowedUDPPorts = [ 68 67 51820 ]; # DHCP and wireguard
      };

      networking.networkmanager = mkIf (!cfg.useNetworkd) {
        enable = true;
        dns = mkForce "dnsmasq";
      };

    };
}
