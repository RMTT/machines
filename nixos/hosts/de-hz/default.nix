{ pkgs, lib, config, modules, modulesPath, ... }:
with lib; {
  imports = with modules; [
    base
    networking
    globals
    services
    ./disk-config.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    ./secrets
  ];

  config = let
    infra_node_ip = "192.168.128.7";
    wan = "enp1s0";
  in {
    system.stateVersion = "24.11";

    hardware.cpu.intel.updateMicrocode = true;
    networking.useNetworkd = true;

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    base.gl.enable = false;

    services.aronet = {
      enable = true;
      config = config.sops.secrets.aronet.path;
      registry = ../common/registry.json;
    };
  };
}
