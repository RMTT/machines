{ pkgs, lib, config, ... }:
with lib; {
  imports =
    [ ../modules/secrets.nix ../modules/base.nix ../modules/networking.nix ../modules/wireguard.nix ];

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
  networking.wireguard.networks = [
    {
      ip = [ "172.31.1.1/24" ];
      privateKeyFile = config.sops.secrets.wg-private.path;

      peers = [
        {
          allowedIPs = [ "172.31.1.2/32" ];
          publicKey = "2nzzD9C33j6loxVcrjfeWvokbUBXpyxEryUk6HN60nE=";
        }
        {
          allowedIPs = [ "172.31.1.3/32" ];
          publicKey = "RYZS5mHgkmjW+/D40Zxn9d/h8NzvN4pzJVbnWK3DbXg=";
        }
				{
					allowedIPs = [ "172.31.1.4/32" ];
					publicKey = "CN+zErqQ3JIlksx51LgY6exZgjDNIGJih73KhO1WpkI=";
				}
      ];
    }
  ];

  sops.secrets.sing-pass = {
    sopsFile = ./config/sing.yaml;
    mode = "0444";
  };
  sops.secrets.sing-pass-algo = {
    sopsFile = ./config/sing.yaml;
    mode = "0444";
  };
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

  networking.firewall.allowedUDPPorts = [ 12345 ];
  networking.firewall.allowedTCPPorts = [ 12346 ];
}
