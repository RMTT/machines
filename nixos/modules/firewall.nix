{ lib, config, pkgs, ... }:
with lib;
let cfg = config.networking.firewall;
in {
  options = {
    networking.firewall = {
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

  config = let
    subnetsV4 = concatStringsSep "," (cfg.trustedSubnets.ipv4);
    subnetsV6 = concatStringsSep "," cfg.trustedSubnets.ipv6;
  in {
    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      logRefusedConnections = false;
      logRefusedUnicastsOnly = false;
      extraInputRules = ''
        ${optionalString (subnetsV4 != "") "ip saddr { ${subnetsV4} } accept"}
        ${optionalString (subnetsV6 != "") "ip6 saddr { ${subnetsV6} } accept"}
      '';
    };
  };
}
