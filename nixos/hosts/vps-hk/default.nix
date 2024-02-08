{ pkgs, config, modules, lib, ... }: {
  imports = with modules; [
    base
    networking
    fs
    docker
    wireguard
		services
    ./secrets.nix
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

  virtualisation.docker.listenTcp = { enable = true; };

  networking.useNetworkd = true;

  networking.wireguard.networks = [
    {
      ip = [ "192.168.128.2/24" ];
      privateKeyFile = config.sops.secrets.wg-private.path;

      peers = [
        {
          allowedIPs = [ "192.168.128.1/24" ];
          publicKey = "nzARKMdkzfy1lMN9xk10yiMfAMzB889NROSa5jvDUBo=";
          endpoint = "portal:30005";
        }
      ];
    }
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.rke2 = {
    enable = true;
    role = "agent";

    configFile = config.sops.secrets.rke2.path;
    params = [ "--node-ip=192.168.128.2" ];
  };
}
