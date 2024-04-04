{ pkgs, lib, modules, config, ... }:
with lib; {
  imports =
    with modules; [ base networking wireguard services ./secrets.nix ];

  config = let infra_node_ip = "192.168.128.1"; in {
    system.stateVersion = "23.05";

    base.gl.enable = false;

    disko.devices = {
      disk = {
        main = {
          device = "/dev/vda";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };

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
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    networking.useNetworkd = true;

    networking.wireguard.networks = [
      {
        ip = [ "${infra_node_ip}/24" ];
        privateKeyFile = config.sops.secrets.wg-private.path;

        peers = [
          {
            allowedIPs = [ "192.168.128.2/32" "192.168.6.0/24" ];
            publicKey = "2nzzD9C33j6loxVcrjfeWvokbUBXpyxEryUk6HN60nE=";
          }
        ];
      }
    ];

    services.sing-box = {
      enable = true;
      settings = {
        log = { level = "warn"; };
        inbounds = [{
          type = "shadowsocks";
          tag = "in";
          listen = "::";
          listen_port = 12346;
          network = "tcp";
          method = { _secret = config.sops.secrets.sing-pass-algo.path; };
          password = { _secret = config.sops.secrets.sing-pass.path; };
        }];
        outbounds = [{
          type = "direct";
          tag = "direct";
        }];
        route.final = "direct";
      };
    };

    networking.firewall.allowedTCPPorts = [ 12346 ];

    services.rke2 = {
      enable = true;
      role = "agent";

      configFile = config.sops.secrets.rke2.path;
      params = [ "--node-ip=192.168.128.1" ];
    };
  };
}
