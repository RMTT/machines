{ pkgs, lib, modules, config, ... }:
with lib; {
  imports =
    with modules; [ base networking wireguard ./secrets.nix ];

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

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking.useNetworkd = true;
  services.resolved = {
    enable = true;
    extraConfig = ''
                  			[Resolve]
      										DNS = 1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google 1.0.0.1#cloudflare-dns.com 8.8.4.4#dns.google
            							DNSOverTLS=yes
                  			'';
  };

  networking.wireguard.networks = [
    {
      ip = [ "192.168.128.1/24" ];
      privateKeyFile = config.sops.secrets.wg-private.path;

      peers = [
        {
          allowedIPs = [ "192.168.128.2/32" ];
          publicKey = "2nzzD9C33j6loxVcrjfeWvokbUBXpyxEryUk6HN60nE=";
        }
        {
          allowedIPs = [ "192.168.128.3/32" ];
          publicKey = "RYZS5mHgkmjW+/D40Zxn9d/h8NzvN4pzJVbnWK3DbXg=";
        }
        {
          allowedIPs = [ "192.168.128.4/32" ];
          publicKey = "CN+zErqQ3JIlksx51LgY6exZgjDNIGJih73KhO1WpkI=";
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

  networking.firewall.allowedUDPPorts = [ 12345 ];
  networking.firewall.allowedTCPPorts = [ 12346 ];
}
