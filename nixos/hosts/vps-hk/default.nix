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

  config =
    let
      infra_node_ip = "192.168.128.2";
      wan = "ens18";
    in
    {
      system.stateVersion = "23.05";

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

      networking.useNetworkd = true;

      services.k3s = {
        enable = true;
        configPath = config.sops.secrets.k3s.path;
        role = "agent";
      };

      # wireguard and udp2raw
      services.udp2raw = {
        enable = true;
        openFirewall = true;
        role = "server";
        remotePort = 51820;
        passwordFile = config.sops.secrets.udp2raw.path;
      };
      networking.wireguard.networks = [
        {
          ip = [ "${infra_node_ip}/24" ];
          privateKeyFile = config.sops.secrets.wg-private.path;
          mtu = 1350;

          peers = [
            {
              allowedIPs = [ "${infra_node_ip}/24" "10.42.0.0/24" ];
              publicKey = "RYZS5mHgkmjW+/D40Zxn9d/h8NzvN4pzJVbnWK3DbXg=";
            }
          ];
        }
      ];

      networking.firewall.allowedTCPPorts = [ 80 443 ];
    };
}
