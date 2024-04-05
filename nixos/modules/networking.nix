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

    								192.168.6.1 router.home.rmtt.host
    								192.168.6.2 homeserver.home.rmtt.host
    								192.168.6.3 pikvm.home.rmtt.host
  '';
in
with lib;
let
  # for 'ip route'
  tableModule = with types; {
    options = {
      name = mkOption {
        type = str;
        default = "main";
      };
    };
  };

  # for 'ip rule'
  ruleModule = with types ; {
    options = {
      priority = mkOption {
        type = int;
        default = 64;
      };

      fwmark = mkOption {
        type = str;
        description = "fwmark for traffic which hit ipset";
      };
    };
  };

  # configuration for how to update ipset
  ipsetModule = with types; {
    options = {
      script = mkOption {
        type = lines;
        default = "";
      };

      interval = mkOption {
        type = str;
        default = "daily";
      };
    };
  };

  routeFromIpsetModule = with types; {
    options = {

      name = mkOption {
        type = str;
        description = "name of nftables set and route table";
      };

      table = mkOption {
        type = (submodule tableModule);
        description = "which route table should use";
        default = { };
      };

      rule = mkOption {
        type = (submodule ruleModule);
        description = "ip rule settings";
      };

      ipset = mkOption {
        type = (submodule ipsetModule);
        default = { };
      };
    };
  };
in
{
  options = {
    networking.bypassSubnet4 = mkOption {
      type = types.listOf types.str;
      default = [ "${defaltLocalSubnet4}" ] ++ wgSubnet4;
    };

    networking.routeFromIpset = mkOption {
      type = types.listOf (types.submodule routeFromIpsetModule);
      default = [ ];
    };
  };

  config =
    let
      subnet4 = builtins.concatStringsSep "," cfg.bypassSubnet4;
    in
    {
      networking.iproute2.enable = true;
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

      networking.useDHCP = false;
      networking.firewall = {
        enable = true;
        checkReversePath = "loose";
        logRefusedConnections = false;
        logRefusedUnicastsOnly = false;
        extraInputRules = "ip saddr {${subnet4}} accept";

        allowedUDPPorts = [ 68 67 ]; # DHCP and wireguard
      };

      networking.networkmanager = mkIf (!cfg.useNetworkd) {
        enable = true;
        dns = mkForce "dnsmasq";
      };

      # for route
      networking.nftables = {
        enable = true;
        flushRuleset = false;

        tables = listToAttrs (lists.imap0
          (i: config:
            {
              name = "nixos-route";
              value = {
                family = "inet";
                enable = true;
                content = ''
                                            set ${config.name}-v4 {
                                    					type ipv4_addr; flags interval;
                                    				}

                                            set ${config.name}-v6 {
                                    					type ipv6_addr; flags interval;
                                    				}

                                    				chain prerouting {
                                    					type filter hook prerouting priority mangle; policy accept;
                                    					ip daddr @${config.name}-v4 ct mark set ${config.rule.fwmark}
                                    					ip daddr @${config.name}-v4 meta mark set ct mark

                                    					ip6 daddr @${config.name}-v6 ct mark set ${config.rule.fwmark}
                                    					ip6 daddr @${config.name}-v6 meta mark set ct mark
                                    				}

                  													chain output {
                  														type route hook output priority filter; policy accept;
                                    					ip daddr @${config.name}-v4 ct mark set ${config.rule.fwmark}
                                    					ip daddr @${config.name}-v4 meta mark set ct mark

                                    					ip6 daddr @${config.name}-v6 ct mark set ${config.rule.fwmark}
                                    					ip6 daddr @${config.name}-v6 meta mark set ct mark
                  												}
                '';
              };
            })
          cfg.routeFromIpset);
      };

      systemd.services = listToAttrs (lists.imap0
        (i: config:
          let
            name = config.name;
            ipsetUpdateScript = ''
                                                      V4_FILE=$STATE_DIRECTORY/ip.v4
                                                      V6_FILE=$STATE_DIRECTORY/ip.v6
              																				NFT_FILE=$STATE_DIRECTORY/${name}.nft

              																				echo -en "flush set inet nixos-route ${name}-v4\n" > $NFT_FILE
              																				echo -en "flush set inet nixos-route ${name}-v6\n" >> $NFT_FILE
              																				echo -en "table inet nixos-route { \n" >> $NFT_FILE

                                                      ${config.ipset.script}

              																				echo -en "set ${name}-v4 {type ipv4_addr; flags interval;\n" >> $NFT_FILE
              																				echo -en "elements={\n" >> $NFT_FILE
              																				mapfile -t lines < $V4_FILE
              																				for line in ''${lines[@]}
              																				do
              																					echo -en "$line," >> $NFT_FILE
              																				done
              																				echo -en "}}\n" >> $NFT_FILE

              																				echo -en "set ${name}-v6 {type ipv6_addr; flags interval;\n" >> $NFT_FILE
              																				echo -en "elements={\n" >> $NFT_FILE
              																				mapfile -t lines < $V6_FILE
              																				for line in ''${lines[@]}
              																				do
              																					echo -en "$line," >> $NFT_FILE
              																				done
              																				echo -en "}}\n" >> $NFT_FILE

              																				echo -en "}" >> $NFT_FILE
              																				nft -f $NFT_FILE
                                          						'';
          in
          {
            name = "route-from-ipset@" + name;
            value = {
              enable = true;
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                Type = "oneshot";
                StateDirectory = "route-from-ipset@${name}";
                StateDirectoryMode = "0750";
              };
              path = with pkgs; [ iproute2 nftables wget curl ];
              preStart = ''ip rule del fwmark ${config.rule.fwmark} lookup ${config.table.name} || true
													ip -6 rule del fwmark ${config.rule.fwmark} lookup ${config.table.name} || true
								'';
              script = ''
                                              ip rule add preference ${toString config.rule.priority} fwmark ${config.rule.fwmark} lookup ${config.table.name}
                                              ip -6 rule add preference ${toString config.rule.priority} fwmark ${config.rule.fwmark} lookup ${config.table.name}
                															${if (config.ipset.script != "") then ipsetUpdateScript else ""}
                															'';

            };
          }
        )
        cfg.routeFromIpset
      );

      systemd.timers = listToAttrs (lists.imap0
        (i: config:
          let name = config.name;
          in
          {
            name = "route-from-ipset@${name}";
            value = {
              enable = true;
              wantedBy = [ "multi-user.target" ];
              timerConfig = {
                OnBootSec = 3;
                OnCalendar = config.ipset.interval;
              };
            };
          }
        )
        cfg.routeFromIpset
      );
      # for route end
    };
}
