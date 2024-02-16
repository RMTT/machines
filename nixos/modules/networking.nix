{ lib, config, pkgs, ... }:
let
  defaltLocalSubnet4 = "192.168.6.1/24";
  wgSubnet4 = [ "192.168.128.0/24" ];
  cfg = config.networking;
  hosts_internet = ''
    				85.237.205.152 portal-original
        		101.227.98.233 portal
        		103.39.79.110 vps-hk
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
			systemd.network.enable = true;

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

        allowedUDPPorts = [ 68 67 12345 ]; # DHCP and wireguard
      };

      networking.networkmanager = mkIf (!cfg.useNetworkd) {
        enable = true;
        dns = "dnsmasq";
      };

      systemd.network.wait-online.anyInterface = mkIf cfg.useNetworkd true;
      systemd.network.networks = mkIf cfg.useNetworkd {
        "dhcp" = {
          matchConfig = {
            Name = "en*";
            Type = "ether";
          };
          networkConfig = { DHCP = "yes"; };
        };
      };
    };
}
