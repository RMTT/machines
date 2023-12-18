{ pkgs, config, lib, ... }: {
  imports = [
    ../modules/secrets.nix
    ../modules/base.nix
    ../modules/networking.nix
    ../modules/fs.nix
    ../modules/docker.nix
		../modules/wireguard.nix
  ];

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
  boot.loader.grub.devices = [ "/dev/sda" ];
  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;
  };

  virtualisation.docker.listenTcp = { enable = true; };

  networking.useNetworkd = true;

  sops.secrets.wg-private = {
    owner = "systemd-network";
    mode = "0400";
    sopsFile = ./keys/wg-private.key;
    format = "binary";
  };
  networking.wireguard.networks = [
    {
      ip = [ "172.31.1.2/24" ];
      privateKeyFile = config.sops.secrets.wg-private.path;

      peers = [
        {
          allowedIPs = [ "172.31.1.1/24" ];
          publicKey = "nzARKMdkzfy1lMN9xk10yiMfAMzB889NROSa5jvDUBo=";
					endpoint = "portal:30005";
        }
      ];
    }
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
