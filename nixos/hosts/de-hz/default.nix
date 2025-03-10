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
  };
}
