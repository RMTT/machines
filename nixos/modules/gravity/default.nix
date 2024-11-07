{ config
, pkgs
, lib
, inputs
, ...
}:
with lib;
let
  cfg = config.services.gravity;

  ranet = pkgs.rustPlatform.buildRustPackage rec {
    pname = "ranet";
    version = "v0.11.0";

    src = pkgs.fetchFromGitHub {
      owner = "NickCao";
      repo = pname;
      rev = version;
      hash = "sha256-GB8FXnHzaM06MivfpYEFFIp4q0WfH3a7+jmoC3Tpwbs=";
    };

    cargoHash = "sha256-+f793L/qYdHaVP3S3wCn0d4URbXzGzgRwwCo5mrIEq8=";
    checkFlags = [
      "--skip=address::test::remote"
    ];
  };
in
{
  imports = [
    ./strongswan.nix
    ./bird.nix
    ./divi.nix
    ./networkd.nix
  ];

  options.services.gravity = {
    enable = mkEnableOption "gravity overlay network, next generation";
    ipsec = {
      enable = mkEnableOption "ipsec";
      organization = mkOption { type = types.str; };
      commonName = mkOption { type = types.str; };
      privateKey = mkOption {
        type = types.path;
        description = "private key file of ipsec";
      };
      port = mkOption {
        type = types.port;
        default = 13000;
      };
      endpoints = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              serialNumber = mkOption { type = types.str; };
              addressFamily = mkOption { type = types.str; };
              address = mkOption {
                type = types.nullOr types.str;
                default = null;
              };
            };
          }
        );
      };
    };
    reload = {
      enable = mkEnableOption "auto reload registry";
      headerFile = mkOption {
        type = types.nullOr types.path;
        description = "header file for curl to fetch gravity registry";
        default = null;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      boot.kernelModules = [ "vrf" ];
      boot.kernel.sysctl = {
        "net.vrf.strict_mode" = 1;
        "net.ipv6.conf.default.forwarding" = 1;
        "net.ipv4.conf.default.forwarding" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "net.ipv4.conf.all.forwarding" = 1;
        # https://www.kernel.org/doc/html/latest/networking/vrf.html#applications
        # established sockets will be created in the VRF based on the ingress interface
        # in case ingress traffic comes from inside the VRF targeting VRF external addresses
        # the connection would silently fail
        "net.ipv4.tcp_l3mdev_accept" = 0;
        "net.ipv4.udp_l3mdev_accept" = 0;
        "net.ipv4.raw_l3mdev_accept" = 0;
      };

      systemd.services.gravity-rules = {
        path = with pkgs; [
          iproute2
          coreutils
        ];
        script = ''
          ip -4 ru del pref 0 || true
          ip -6 ru del pref 0 || true
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        after = [ "network-pre.target" ];
        before = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
      };


    })
    (mkIf cfg.reload.enable {
      systemd.tmpfiles.rules = [ "d /var/lib/gravity 0755 root root - -" ];
      systemd.services.gravity-registry = {
        path = with pkgs; [
          curl
          jq
          coreutils
        ];
        script = ''
          set -euo pipefail
          for filename in registry.json combined.json
          do
            curl --fail --retry 3 --retry-connrefused \
              -H @${cfg.reload.headerFile} \
              https://raw.githubusercontent.com/tuna/gravity/artifacts/artifacts/$filename --output /var/lib/gravity/$filename.new
            mv /var/lib/gravity/$filename.new /var/lib/gravity/$filename
          done
          /run/current-system/systemd/bin/systemctl reload-or-restart --no-block gravity-ipsec || true
        '';
        serviceConfig.Type = "oneshot";
      };
      systemd.timers.gravity-registry = {
        timerConfig = {
          OnCalendar = "*:0/15";
        };
        wantedBy = [ "timers.target" ];
      };
    })
    (mkIf cfg.ipsec.enable {
      environment.systemPackages = [ pkgs.strongswan ];
      environment.etc."ranet/config.json".source = (pkgs.formats.json { }).generate "config.json" {
        organization = cfg.ipsec.organization;
        common_name = cfg.ipsec.commonName;
        endpoints = builtins.map
          (ep: {
            serial_number = ep.serialNumber;
            address_family = ep.addressFamily;
            address = ep.address;
            port = cfg.ipsec.port;
            updown = pkgs.writeShellScript "updown" ''
              LINK=gn$(printf '%08x\n' "$PLUTO_IF_ID_OUT")
              case "$PLUTO_VERB" in
                up-client)
                  ip link add "$LINK" type xfrm if_id "$PLUTO_IF_ID_OUT"
                  ip link set "$LINK" master gravity multicast on mtu 1400 up
                  ;;
                down-client)
                  ip link del "$LINK"
                  ;;
              esac
            '';
          })
          cfg.ipsec.endpoints;
      };
      systemd.services.gravity-ipsec =
        let
          command = "ranet -c /etc/ranet/config.json -r /var/lib/gravity/registry.json -k ${cfg.ipsec.privateKey}";
        in
        {
          path = [
            ranet
            pkgs.iproute2
          ];
          script = "${command} up";
          reload = "${command} up";
          preStop = "${command} down";
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          unitConfig = {
            AssertFileNotEmpty = "/var/lib/gravity/registry.json";
          };
          bindsTo = [ "strongswan-swanctl.service" ];
          wants = [
            "network-online.target"
            "strongswan-swanctl.service"
          ];
          after = [
            "network-online.target"
            "strongswan-swanctl.service"
          ];
          wantedBy = [ "multi-user.target" ];
          reloadTriggers = [ config.environment.etc."ranet/config.json".source ];
        };
    })
  ]);
}
