{ config, lib, ... }:
with lib;
let cfg = config.fs;
in {
  options.fs = {
    btrfs = {
      device = mkOption {
        type = types.str;
        description = ''
          Parition label for btrfs.
        '';
      };

      volumes = mkOption {
        type = types.attrs;
        description = ''
          Mappings of filesystem path to btrfs subvolume, for example:
        '';
        example = {
          "/" = [ "subvol=@" ];
          "/home" = [ "subvol=@home" ];
        };
      };
    };

    normal.volumes = mkOption {
      type = types.attrs;
      default = { };
      example = {
        "/" = {
          fsType = "ext4";
          device = "label";
          options = options;
        };
      };
      description = ''
        mount filesystems.
      '';
    };

    swap.device = mkOption {
      type = types.str;
      default = "";
      description = ''
        label of swap device
      '';
    };

    boot.device = mkOption {
      type = types.str;
      description = ''
        Partition UUID of boot partition.
      '';
    };

  };

  config = let
    btrfs = mapAttrs (_: options: {
      device = "/dev/disk/by-label/${cfg.btrfs.device}";
      fsType = "btrfs";
      options = options;
    }) cfg.btrfs.volumes;

    others = mapAttrs (_: params: {
      fsType = params.fsType;
      device = "/dev/disk/by-label/${params.device}";
      options = mkIf (params.options != [ ]) params.options;
    }) cfg.normal.volumes;

    boot = {
      "/boot" = {
        device = "/dev/disk/by-label/${cfg.boot.device}";
        fsType = "vfat";
      };
    };
  in {
    fileSystems = (btrfs // others // boot);

    swapDevices = mkIf (cfg.swap.device != "") [{
      device = "/dev/disk/by-label/${cfg.swap.device}";
    }];

  };
}
