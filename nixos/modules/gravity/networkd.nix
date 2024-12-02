{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.gravity;

  stateful = config.systemd.network.netdevs.stateful.vrfConfig.Table;
  stateless = config.systemd.network.netdevs.stateless.vrfConfig.Table;
in {
  options = {
    services.gravity = {
      table = mkOption {
        type = types.int;
        default = 200;
        description = "routing table number for the vrf interface";
      };
      address = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = "list of addresses to be added to the vrf interface";
      };
      srv6 = {
        enable = mkEnableOption "sample srv6 configuration";
        prefix = mkOption {
          type = types.str;
          description = "prefix for srv6 actions";
        };
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      systemd.network.enable = true;

      systemd.network.config.networkConfig = { ManageForeignRoutes = false; };

      systemd.network.netdevs = {
        gravity = {
          netdevConfig = {
            Kind = "vrf";
            Name = "gravity";
          };
          vrfConfig = { Table = cfg.table + 0; };
        };
        stateful = {
          netdevConfig = {
            Kind = "vrf";
            Name = "stateful";
          };
          vrfConfig = { Table = cfg.table + 1; };
        };
        stateless = {
          netdevConfig = {
            Kind = "vrf";
            Name = "stateless";
          };
          vrfConfig = { Table = cfg.table + 2; };
        };
      };

      systemd.network.networks = {
        gravity = {
          name = config.systemd.network.netdevs.gravity.netdevConfig.Name;
          address = cfg.address;
          linkConfig.RequiredForOnline = false;
          routingPolicyRules = lib.optionals (cfg.srv6.enable) [{
            Priority = 500;
            Family = "ipv6";
            Table = 100; # localsid
            From = "2a0c:b641:69c::/48";
            To = "${cfg.srv6.prefix}6::/64";
          }] ++ [{
            Priority = 3000;
            Family = "both";
            Table = "local";
          }];
          # TODO: remove following lines when upstream supports L3MasterDevice
          extraConfig = ''
            [RoutingPolicyRule]
            Priority=2000
            Family=both
            L3MasterDevice=true
            Type=unreachable
                        					'';
        };
        stateful = {
          name = config.systemd.network.netdevs.stateful.netdevConfig.Name;
          linkConfig.RequiredForOnline = false;
        };
        stateles = {
          name = config.systemd.network.netdevs.stateless.netdevConfig.Name;
          linkConfig.RequiredForOnline = false;
        };
      };
    }

    (mkIf cfg.srv6.enable {
      environment.etc."iproute2/rt_tables.d/gravity.conf" = {
        mode = "0644";
        text = ''
          100 localsid
          ${toString stateless} stateless
          ${toString stateful} stateful
        '';
      };
      systemd.services.gravity-srv6 = {
        path = with pkgs; [ iproute2 ];
        serviceConfig = let
          routes = [
            "blackhole default table localsid"
            "${cfg.srv6.prefix}6::1 encap seg6local action End.DT6 vrftable stateless dev gravity table localsid"
            "${cfg.srv6.prefix}6::2 encap seg6local action End                       dev gravity table localsid"
            "${cfg.srv6.prefix}6::3 encap seg6local action End.DT6 vrftable stateful dev gravity table localsid"
          ];
        in {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart =
            builtins.map (route: "${pkgs.iproute2}/bin/ip -6 r a ${route}")
            routes;
          ExecStop =
            builtins.map (route: "${pkgs.iproute2}/bin/ip -6 r d ${route}")
            routes;
        };
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
      };
    })
  ]);
}
