{ pkgs, lib, config, modules, modulesPath, ... }:
with lib; {
  imports = with modules; [
    base
    networking
    globals
    godel
    ./disk-config.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    ./secrets
  ];

  config = let
    infra_node_ip = "192.168.128.7";
    infra_network = "fd97:1208:0:4::1/64";
    wan = "enp1s0";
  in {
    system.stateVersion = "24.11";

    hardware.cpu.intel.updateMicrocode = true;
    networking.useNetworkd = true;

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    base.gl.enable = false;

    services.godel = {
      enable = true;
      network = infra_network;
      netns = true;
      prefixs = [ "${infra_node_ip}/32" "10.42.2.0/24" ];
      extra_ip = [ "${infra_node_ip}/32" ];
      public = true;

      k3s = {
        enable = true;
        node-ip = infra_node_ip;
        role = "agent";
      };
    };

    services.prometheus = {
      globalConfig.scrape_interval = "1m";
      enable = true;
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [{
            targets = [
              "de-hz.infra.rmtt.host:${
                toString config.services.prometheus.port
              }"
            ];
          }];
        }
        {
          job_name = "node";
          static_configs = [{
            targets = [
              "de-hz.infra.rmtt.host:${
                toString config.services.prometheus.exporters.node.port
              }"

              "homeserver.infra.rmtt.host:${
                toString config.services.prometheus.exporters.node.port
              }"

              "cn2-la.infra.rmtt.host:${
                toString config.services.prometheus.exporters.node.port
              }"
            ];
          }];
        }
        {
          job_name = "smartctl";
          static_configs = [{
            targets = [
              "homeserver.infra.rmtt.host:${
                toString config.services.prometheus.exporters.smartctl.port
              }"
            ];
          }];
        }
      ];

      remoteWrite = [{
        url =
          "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push";
        basic_auth = {
          username = "2319367";
          password_file = config.sops.secrets.grafana-token.path;
        };
      }];

      exporters.node.enable = true;
    };
  };
}
