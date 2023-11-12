{ pkgs, config, lib, ... }: {
  imports = [
    ../modules/secrets.nix
    ../modules/base.nix
    ../modules/networking.nix
    ../modules/fs.nix
    ../modules/docker.nix
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


  virtualisation.docker.listenTcp = {
    enable = true;
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
    wireguardPeers = [{
      wireguardPeerConfig = {
        AllowedIPs = [ "172.31.1.0/24" ];
        Endpoint = "portal:30005";
        PersistentKeepalive = 15;
        PublicKey = "nzARKMdkzfy1lMN9xk10yiMfAMzB889NROSa5jvDUBo=";
      };
    }];
  };
  systemd.network.networks."wg0" = {
    matchConfig = { Name = "wg0"; };
    networkConfig = { Address = "172.31.1.2/24"; };
  };

  networking.firewall.allowedTCPPorts = [
    2376 # for docker
    80
    443
  ];

  networking.firewall.allowedUDPPorts = [ 12345 ];
}
