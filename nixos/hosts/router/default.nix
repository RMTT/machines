{ pkgs, lib, modules, config, ... }:
with lib; {
  imports = with modules; [
    services
    base
    fs
    networking
    wireguard
    ./secrets.nix
  ];

  config =
    let
      lan = [ "enp1s0" "enp2s0" "enp3s0" ];
      wan = "enp4s0";

      lan_gateway = "192.168.6.1"; # for DHCP and nat
      lan_ip_prefix = 24;
      lan_ip_mask = "255.255.255.0";
      lan_ip_start = "192.168.6.10";
      lan_ip_end = "192.168.6.233";

      infra_node_ip = "192.168.128.3";
    in
    {
      system.stateVersion = "23.05";
      base.gl.enable = false;

      fs.normal.volumes = {
        "/" = {
          fsType = "ext4";
          label = "@";
          options =
            [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
        };
      };
      fs.boot.label = "@boot";

      hardware.cpu.intel.updateMicrocode = true;

      # disable docker
      virtualisation.docker.enable = mkForce false;

      boot.kernel.sysctl = {
        # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
        # By default, not automatically configure any IPv6 addresses.
        "net.ipv6.conf.all.accept_ra" = 0;
        "net.ipv6.conf.all.autoconf" = 0;
        "net.ipv6.conf.all.use_tempaddr" = 0;

        # On WAN, allow IPv6 autoconfiguration and tempory address use.
        "net.ipv6.conf.${wan}.accept_ra" = 2;
        "net.ipv6.conf.${wan}.autoconf" = 1;
      };

      networking.useNetworkd = true;
      networking.bridges = {
        lan = { interfaces = lan; };
        wan = { interfaces = [ wan ]; };
      };
      # bypass lan
      networking.firewall.trustedInterfaces = [ "lan" "tailscale0" ];
      systemd.network = {
        networks = {
          wan = {
            name = "wan";
            networkConfig = { DHCP = "yes"; };
            dhcpV6Config = { WithoutRA = "solicit"; };
            dhcpPrefixDelegationConfig = {
              UplinkInterface = ":self";
              SubnetId = 0;
              Announce = "no";
            };
          };
          lan = {
            name = "lan";
            linkConfig = {
              ActivationPolicy = "always-up";
            };
            networkConfig = {
              Address = "${lan_gateway}/${toString lan_ip_prefix}";
              ConfigureWithoutCarrier = "yes";
              IgnoreCarrierLoss = "yes";
              IPv6AcceptRA = "no";
              IPv6SendRA = "yes";
              DHCPPrefixDelegation = "yes";
            };
            dhcpPrefixDelegationConfig = {
              UplinkInterface = "wan";
              SubnetId = 1;
              Announce = "yes";
            };
          };
        };
      };
      services.resolved.extraConfig = ''
              DNS = 127.0.0.1 ::1 223.5.5.5 223.6.6.6
              DNSStubListener = false
        			DNSSEC = false
      '';

      # enable nat from lan
      networking.nat = {
        enable = true;
        internalIPs = [
          "${lan_gateway}/${toString lan_ip_prefix}"
          "198.18.0.1/30" # clash tun ip
        ];
        externalInterface = "wan";
      };

      # enable clash and adguardhome (for DNS)
      services.clash = {
        enable = true;
        config = config.sops.secrets.clash_config.path;
      };

      services.adguardhome = {
        enable = true;
        openFirewall = true;
      };

      services.kea = {
        dhcp4 = {
          enable = true;
          settings = {
            option-data = [
              {
                name = "domain-name-servers";
                data = "192.168.6.1";
                always-send = true;
              }

              {
                name = "routers";
                data = "192.168.6.1";
              }
            ];
            interfaces-config = {
              interfaces = [
                "lan"
              ];
              service-sockets-require-all = true;
              service-sockets-max-retries = 50;
              service-sockets-retry-wait-time = 5000;
            };
            subnet4 = [
              {
                id = 1;
                pools = [
                  {
                    pool = "192.168.6.10 - 192.168.6.240";
                  }
                ];
                subnet = "192.168.6.0/24";
                reservations = [
                  {
                    hw-address = "f4:b5:20:5d:1f:e7";
                    hostname = "homeserver";
                    ip-address = "192.168.6.2";
                  }
                  {
                    hw-address = "9e:20:b6:6d:b6:50";
                    hostname = "pikvm";
                    ip-address = "192.168.6.3";
                  }
                ];
              }
            ];
          };
        };
      };

      # wireguard and udp2raw
      services.udp2raw = {
        enable = true;
        localAddress = "127.0.0.1";
        openFirewall = false;
        remoteAddress = "103.39.79.110";
        role = "client";
        passwordFile = config.sops.secrets.udp2raw.path;
      };

      networking.nftables.ruleset = ''
        table ip nat {
        	chain postrouting {
        		type nat hook postrouting priority 100 ;
        		ip saddr != {${infra_node_ip}/24} oifname "wg0" masquerade
        	}
        }
        				'';
      networking.wireguard.networks = [
        {
          ip = [ "${infra_node_ip}/24" ];
          privateKeyFile = config.sops.secrets.wg-private.path;
          mtu = 1350;

          peers = [
            {
              # homeserver
              allowedIPs = [ "192.168.128.4/32" "10.42.0.0/24" ];
              publicKey = "CN+zErqQ3JIlksx51LgY6exZgjDNIGJih73KhO1WpkI=";
            }
          ];
        }
      ];

      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      networking.routeFromIpset = [
        {
          rule = {
            fwmark = "6";
          };
          name = "chnroute";

          ipset = {
            script = ''
              					wget https://raw.githubusercontent.com/fernvenue/chn-cidr-list/master/ipv4.txt -O $V4_FILE
              					wget https://raw.githubusercontent.com/fernvenue/chn-cidr-list/master/ipv6.txt -O $V6_FILE
            '';
          };
        }
      ];
    };
}
