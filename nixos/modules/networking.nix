{ lib, config, pkgs, ... }:
let
  cfg = config.networking;
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
  imports = [ ./firewall.nix ];
  options = {
    networking.routeFromIpset = mkOption {
      type = types.listOf (types.submodule routeFromIpsetModule);
      default = [ ];
    };
  };

  config =
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
        # enable dhcp on all interface with prefix "en*"
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

      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = mkDefault 1;
        "net.ipv6.conf.all.forwarding" = mkDefault 1;
        "net.ipv4.conf.all.route_localnet" = mkDefault 1;
      };

      networking.useDHCP = false;

      networking.networkmanager = mkIf (!cfg.useNetworkd) {
        enable = true;
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
            ipsetUpdateScript = pkgs.writeScript "route-from-ipset" ''
              							V4_FILE=$STATE_DIRECTORY/ip.v4
                          	V6_FILE=$STATE_DIRECTORY/ip.v6
                          	NFT_FILE=$STATE_DIRECTORY/${name}.nft

              							setupRouteV4() {
              								echo -en "flush set inet nixos-route ${name}-v4\n" > $NFT_FILE
              								echo -en "table inet nixos-route { \n" >> $NFT_FILE
              								echo -en "set ${name}-v4 {type ipv4_addr; flags interval;\n" >> $NFT_FILE
                          		echo -en "elements={\n" >> $NFT_FILE
                          		mapfile -t lines < $V4_FILE
                          		for line in ''${lines[@]}
                          		do
                          			echo -en "$line," >> $NFT_FILE
                          		done
                          		echo -en "}}\n" >> $NFT_FILE

                          		echo -en "}" >> $NFT_FILE
                          		nft -f $NFT_FILE
              							}

              							setupRouteV6() {
              								echo -en "flush set inet nixos-route ${name}-v6\n" > $NFT_FILE
              								echo -en "table inet nixos-route { \n" >> $NFT_FILE
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
              							}

              							if [ -e $V4_FILE ]; then
              								setupRouteV4
              							fi

              							if [ -e $V6_FILE ]; then
              								setupRouteV4
              							fi

                          	${config.ipset.script}

              							if [ -e $V4_FILE ]; then
              								setupRouteV4
              							fi

              							if [ -e $V6_FILE ]; then
              								setupRouteV4
              							fi
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
