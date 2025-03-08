{ pkgs, lib, config, modules, ... }:
with lib; {
  imports = with modules; [
    base
    networking
    globals
    "${pkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ];

  config = let
    infra_node_ip = "192.168.128.6";
    wan = "eth0";
  in {
    system.stateVersion = "25.05";

    hardware.cpu.amd.updateMicrocode = true;
    networking.useNetworkd = true;

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    fs.normal.volumes = {
      "/" = {
        fsType = "ext4";
        label = "@";
        options =
          [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
      };
    };
    fs.swap.label = "@swap";
  };
}
