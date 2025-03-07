{ pkgs, lib, config, modules, ... }:
with lib; {
  imports = with modules; [
    base
    networking
    globals
    ./disk-config.nix
  ];

  config = let
    infra_node_ip = "192.168.128.6";
    wan = "ens3";
  in {
    system.stateVersion = "25.05";

    hardware.cpu.amd.updateMicrocode = true;
    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "virtio_blk"
      "virtio_net"
      "virtio"
      "sd_mod"
      "sr_mod"
    ];

    networking.useNetworkd = true;

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  };
}
