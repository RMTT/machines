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
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = let
    infra_node_ip = "192.168.128.5";
    infra_network = "fd97:1208:0:2::1/64";
    wan = "ens3";
  in {
    system.stateVersion = "24.11";

    hardware.cpu.intel.updateMicrocode = true;
    networking.useNetworkd = true;

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    base.gl.enable = false;
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

    services.godel = {
      enable = true;
      network = infra_network;
      netns = true;
      prefixs = [ "${infra_node_ip}/32" "10.42.1.0/24" ];
      extra_ip = [ "${infra_node_ip}/32" ];
      public = true;

      k3s = {
        enable = true;
        node-ip = infra_node_ip;
        role = "agent";
      };
    };

    services.prometheus = { exporters.node.enable = true; };
  };
}
