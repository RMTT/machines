{ pkgs, lib, config, ... }: {
  config = {
    services.mihomo = {
      enable = true;
      webui = pkgs.metacubexd;
      configFile = config.sops.secrets.clash.path;
    };

    networking.nftables.tables.netflow = {
      name = "netflow";
      content = ''
        define TPROXY_PORT=7890

        set bypass4 {
          type ipv4_addr;
        }

        set bypass6 {
          type ipv6_addr;
        }

        chain output {
          type route hook output priority mangle; policy accept;
        }

        chain prerouting {
          type filter hook prerouting priority mangle; policy accept;
        }

        chain proxy_redirect {
          ip daddr @bypass4 return
          ip6 daddr @bypass6 return
          meta protocol ip meta l4proto tcp tproxy ip to 127.0.0.1:$PROXY_PORT
          meta protocol ip6 meta l4proto tcp tproxy ip6 to [::1]:$PROXY_PORT
        }
      '';
      family = "inet";
    };
  };
}
