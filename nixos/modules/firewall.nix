{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.networking.firewall;

  localSubnets = [ "192.168.128.0/24" "192.168.6.1/24" ];

  ifaceSet = concatStringsSep ", " (
    map (x: ''"${x}"'') cfg.trustedInterfaces
  );

  subnetsV4 = concatStringsSep "," (cfg.trustedSubnets.ipv4 ++ localSubnets);
  subnetsV6 = concatStringsSep "," cfg.trustedSubnets.ipv6;

  portsToNftSet = ports: portRanges: concatStringsSep ", " (
    map (x: toString x) ports
    ++ map (x: "${toString x.from}-${toString x.to}") portRanges
  );
in
{
  options = {
    networking.firewall = {
      # kubernetes and docker always capture traffic in prerouting, which will break our firewall
      prerouting = mkEnableOption "copy input-allow to prerouting hook";

      trustedSubnets = {
        ipv4 = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        ipv6 = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
      };
    };
  };

  config = {
    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      logRefusedConnections = false;
      logRefusedUnicastsOnly = false;
      extraInputRules = ''
                        ${optionalString (subnetsV4 != "") "ip saddr { ${subnetsV4} } accept"}
                        ${optionalString (subnetsV6 != "") "ip6 saddr { ${subnetsV6} } accept"}
        																'';

      allowedUDPPorts = [ 68 67 ]; # DHCP and wireguard
    };

    networking.nftables.tables."nixos-fw-for-pre" = mkIf cfg.prerouting {
      family = "inet";
      content =
        let
          tcpSet = portsToNftSet cfg.allowedTCPPorts cfg.allowedTCPPortRanges;
          udpSet = portsToNftSet cfg.allowedUDPPorts cfg.allowedUDPPortRanges;
        in
        ''
                                      chain pre {
                                        	type filter hook prerouting priority mangle; policy accept;

          																ct state established,related accept

                                          ${optionalString (subnetsV4 != "") "ip saddr { ${subnetsV4} } accept"}
                                          ${optionalString (subnetsV6 != "") "ip6 saddr { ${subnetsV6} } accept"}
                    											${optionalString (ifaceSet != "") ''iifname { ${ifaceSet} } accept comment "trusted interfaces"''}

                              						${optionalString (tcpSet != "") "tcp dport != { ${tcpSet} } drop"}
                                          ${optionalString (udpSet != "") "udp dport != { ${udpSet} } drop"}

                              				}'';
    };
  };
}
