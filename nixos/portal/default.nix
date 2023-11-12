{ pkgs, lib, config, ... }:
with lib; {
  imports =
    [ ../modules/secrets.nix ../modules/base.nix ../modules/networking.nix ];

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
    "virtio"
    "sd_mod"
    "sr_mod"
  ];
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking.useNetworkd = true;

  sops.secrets.wg-private = {
    owner = "systemd-network";
    mode = "0400";
    sopsFile = ./keys/wg-private.key;
    format = "binary";
  };

  systemd.network.netdevs."wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
    };
    wireguardConfig = {
      ListenPort = 12345;
      PrivateKeyFile = config.sops.secrets.wg-private.path;
    };
    wireguardPeers = [
      {
        wireguardPeerConfig = {
          AllowedIPs = [ "172.31.1.2/32" ];
          PersistentKeepalive = 15;
          PublicKey = "2nzzD9C33j6loxVcrjfeWvokbUBXpyxEryUk6HN60nE=";
        };
      }
      {
        wireguardPeerConfig = {
          AllowedIPs = [ "172.31.1.3/32" "192.168.6.1/24" ];
          PersistentKeepalive = 15;
          PublicKey = "RYZS5mHgkmjW+/D40Zxn9d/h8NzvN4pzJVbnWK3DbXg=";
        };
      }
    ];
  };
  systemd.network.networks."wg0" = {
    matchConfig = { Name = "wg0"; };
    networkConfig = { Address = "172.31.1.1/24"; };
  };

  networking.firewall.allowedUDPPorts = [ 12345 ];
}
