{ pkgs, lib, config, modules, modulesPath, ... }:
with lib; {
  imports = with modules; [
    base
    networking
    globals
    gravity
    godel
    services
    ./disk-config.nix
    ./secrets
    "${pkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ];

  config = let
    infra_node_ip = "192.168.128.5";
    wan = "ens3";
  in {
    system.stateVersion = "24.11";

    hardware.cpu.intel.updateMicrocode = true;
    networking.useNetworkd = true;

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    services.gravity = {
      enable = true;
      ipsec = {
        enable = true;
        organization = "rmtt.tech";
        commonName = "cn2-la";
        privateKey = config.sops.secrets.gravity-private.path;
        endpoints = [{
          serialNumber = "0";
          addressFamily = "ip4";
          address = "cn2-la.rmtt.host";
        }];
      };
      reload = {
        enable = true;
        headerFile = config.sops.secrets.header.path;
      };
      strongswan = { interfaces = [ "ens3" ]; };
      address = [ "2a0c:b641:69c:5210::1/60" ];
      bird = {
        enable = true;
        prefix = "2a0c:b641:69c:5210::/60";
      };
      divi = {
        enable = true;
        prefix = "2a0c:b641:69c:5214:0:4::/96";
      };
      srv6 = {
        enable = true;
        prefix = "2a0c:b641:69c:521";
      };
    };

    services.k3s = {
      enable = true;
      configPath = config.sops.secrets.k3s.path;
      role = "agent";
      extraFlags = [
        "--node-ip ${infra_node_ip}"
        "--node-external-ip ${infra_node_ip}"
        "--flannel-iface godel"
      ];
    };
    services.godel = {
      enable = true;
      cert = ./secrets/godel.cert;
      privateKey = config.sops.secrets.godel-private.path;
      address = "${infra_node_ip}";
      internet = true;
      remoteId = "homeserver.infra.rmtt.host";
      interface = "${wan}";
    };
    services.aronet = {
      enable = true;
      config = config.sops.secrets.aronet.path;
      registry = ../common/registry.json;
    };
  };
}
