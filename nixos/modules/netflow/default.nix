# services order: mihomo + netflow -> netflow-update -> mosdns
# workflow: after mihomo launched, it'd download subcriptions and this process doesn't need outer dns.
# Then the proxy can be used to download other resources(netflow-update)
# dns cache located in clash and mosdns
{ pkgs, lib, config, ... }:
let
  stateDir = "/var/lib/netflow";
  fwmark = "5000";
  cfg = config.services.netflow;
in {
  options = {
    services.netflow = { interface = lib.mkOption { type = lib.types.str; }; };
  };
  imports = [ ./secrets.nix ];
  config = {
    boot.kernelModules = [ "nf_tproxy_ipv6" "nf_tproxy_ipv4" "nft_tproxy" ];

    services.mihomo = {
      enable = true;
      webui = pkgs.metacubexd;
      configFile = config.sops.secrets.clash.path;
      tunMode = true;
    };

    systemd.services.netflow = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 pkgs.coreutils ];
      script = ''
        if [ ! -d "${stateDir}" ]; then
          mkdir -p ${stateDir}
        fi

        ip ru add priority 32000 fwmark ${fwmark} lookup 200 || true

        ip r flush table 200 || true
        ip r add local 0.0.0.0/0 dev lo table 200 || true

        # create filter lists
        if [ ! -e "${stateDir}/chnlist.txt" ]; then
          touch "${stateDir}/chnlist.txt"
        fi
        cp ${./sets/direct_domains.txt} "${stateDir}/direct_domains.txt"
      '';
      serviceConfig = { Type = "oneshot"; };
    };

    systemd.services.netflow-update = {
      after = [ "netflow.service" "network-online.service" "mihomo.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        (pkgs.python3.withPackages (pypkgs: with pypkgs; [ requests ]))
        pkgs.curl
      ];
      environment = {
        HTTP_PROXY = "http://127.0.0.1:7891";
        HTTPS_PROXY = "http://127.0.0.1:7891";
      };
      script = ''
        until curl -I -s https://www.google.com >/dev/null
        do
          echo "wait to that i can visit internet..."
          sleep 10
        done

        python ${./update.py} ${stateDir}/chnlist.txt.new

        old_md5=$(md5sum ${stateDir}/chnlist.txt)
        new_md5=$(md5sum ${stateDir}/chnlist.txt.new)

        if [ "$old_md5" = "$new_md5" ]; then
          mv ${stateDir}/chnlist.txt.new ${stateDir}/chnlist.txt
          systemctl restart mosdns || true
        fi
      '';
      serviceConfig = { Type = "oneshot"; };
    };
    systemd.timers.netflow-update = {
      after = [ "netflow.service" "network-online.service" "mihomo.service" ];
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "netflow-update.service";
      };
    };

    # mosdns needs chnlist for work, so wait until netflow-update completing
    systemd.services.mosdns = {
      after = [ "mihomo.service" "netflow.service" "netflow-update.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.mosdns ];
      script = "mosdns start -c ${./mosdns.yaml}";
      serviceConfig = { Type = "simple"; };
    };

    networking.nftables.tables.netflow = {
      name = "netflow";
      content = ''
        define TPROXY_PORT=7890
        define FWMARK=${fwmark}
        define PROXY_MARK=5001

        define proxy_protocols = { tcp }

        include "${./sets/reserve.nft}"
        include "${./sets/proxy.nft}"

        set proxy4 {
          type ipv4_addr;
          flags interval
          auto-merge
          elements = $proxy_v4
        }

        set proxy6 {
          type ipv6_addr;
          flags interval
          auto-merge
        }

        chain output {
          type route hook output priority mangle; policy accept;

          oifname != ${cfg.interface} return
          meta mark $PROXY_MARK return comment "traffic from proxy"

          # common rules
          meta l4proto != $proxy_protocols return comment "filter protocols to proxy"

          ip dscp 4 return comment "direct traffic"
          ip6 dscp 4 return comment "direct traffic"

          fib daddr type {local,broadcast,anycast,multicast} return

          ip daddr $reserve_v4 return
          ip6 daddr $reserve_v6 return

          ip daddr != @proxy4 return
          ip6 daddr != @proxy6 return

          ip protocol tcp meta mark set $FWMARK
        }

        chain prerouting {
          type filter hook prerouting priority mangle; policy accept;

          iifname ${cfg.interface} return comment "packets from internet"

          # common rules
          meta l4proto != $proxy_protocols return comment "filter protocols to proxy"

          ip dscp 4 return comment "direct traffic"
          ip6 dscp 4 return comment "direct traffic"

          fib daddr type {local,broadcast,anycast,multicast} return

          ip daddr $reserve_v4 return
          ip6 daddr $reserve_v6 return

          ip daddr != @proxy4 return
          ip6 daddr != @proxy6 return

          meta l4proto tcp tproxy ip to :$TPROXY_PORT meta mark set $FWMARK
        }
      '';
      family = "inet";
    };

    networking.firewall.extraReversePathFilterRules =
      "meta mark ${fwmark} accept";
  };
}
