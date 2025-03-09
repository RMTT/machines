{ pkgs, lib, config, modules, modulesPath, ... }:
with lib; {
  imports = with modules; [
    base
    fs
    networking
    globals
    godel
    (modulesPath + "/profiles/qemu-guest.nix")
    ./secrets
  ];

  config = let
    infra_node_ip = "192.168.128.6";
    infra_network = "fd97:1208:0:3::1/64";
    wan = "eth0";
  in {
    system.stateVersion = "25.05";

    hardware.cpu.amd.updateMicrocode = true;
    networking.useNetworkd = true;

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    base.gl.enable = false;
    fs.normal.volumes = {
      "/" = {
        fsType = "ext4";
        label = "@";
        options =
          [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
      };
    };
    fs.swap.label = "@swap";

    services.godel = {
      enable = true;
      network = infra_network;
      prefixs = [ "${infra_node_ip}/32" ];
      extra_ip = [ "${infra_node_ip}/32" ];
      public = true;
    };
  };
}
