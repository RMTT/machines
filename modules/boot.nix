{ config, lib, ... }:
with lib;
let cfg = config.boot;
in {
  options.boot = {
    device = mkOption {
      type = types.str;
      description = ''
        Partition UUID of boot partition.
      '';
    };
  };

  config = {
    # boot device
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/${cfg.device}";
      fsType = "vfat";
    };

    # bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # common initrd options
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
      "btrfs"
      "iwlwifi"
      "iwlmvm"
    ];
  };
}
