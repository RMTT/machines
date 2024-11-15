{ pkgs, lib, config, modules, ... }:
with lib; {
  imports = with modules; [
    base
    networking
    globals
    gravity
    ./disk-config.nix
    ./secrets.nix
  ];

  config = {
    system.stateVersion = "24.11";

    hardware.cpu.intel.updateMicrocode = true;
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

    networking.firewall.allowedUDPPorts = [
      config.services.gravity.ipsec.port
      6696 # for babel
    ];

    services.gravity = {
      enable = true;
      ipsec = {
        enable = true;
        organization = "rmtt.tech";
        commonName = "cn2-la";
        privateKey = config.sops.secrets.ipsec-private.path;
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
        prefix = "2a0c:b641:69c:5210:8964::/96";
      };
      srv6 = {
        enable = true;
        prefix = "2a0c:b641:69c:521";
      };
    };

    systemd.network.netdevs.k3s = {
      netdevConfig = {
        Kind = "dummy";
        Name = "k3s";
      };
    };

    systemd.network.networks.k3s = {
      matchConfig = { Name = "k3s"; };

      networkConfig = {
        Address = "192.168.128.32";
        Description = "NIC for k3s";
      };
    };
  };
}
