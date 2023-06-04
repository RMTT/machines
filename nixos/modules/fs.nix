{ config, lib, ... }:
with lib;
let cfg = config.fs;
in {
  options.fs = {
    btrfs = {
      device = mkOption {
        type = types.str;
        default = "";
        description = ''
          Parition label for btrfs.
        '';
      };

      volumes = mkOption {
        type = types.attrs;
        default = { };
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
      default = "";
      description = ''
        Partition label of boot partition.
      '';
    };

  };

  config = let
    btrfs = if cfg.btrfs.device != "" then
      mapAttrs (_: options: {
        device = "/dev/disk/by-label/${cfg.btrfs.device}";
        fsType = "btrfs";
        options = options;
      }) cfg.btrfs.volumes
    else
      { };

    others = mapAttrs (_: params: {
      fsType = params.fsType;
      device = "/dev/disk/by-label/${params.device}";
      options = mkIf (params.options != [ ]) params.options;
    }) cfg.normal.volumes;

    boot = if cfg.boot.device != "" then {
      "/boot" = {
        device = "/dev/disk/by-label/${cfg.boot.device}";
        fsType = "vfat";
      };
    } else
      { };
  in {
    fileSystems = (btrfs // others // boot);

    swapDevices = mkIf (cfg.swap.device != "") [{
      device = "/dev/disk/by-label/${cfg.swap.device}";
    }];

  };
}
