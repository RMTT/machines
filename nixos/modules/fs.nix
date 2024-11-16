{ config, lib, ... }:
with lib;
let
  cfg = config.fs;
  volumesMap = with lib.types; {
    options = {
      fsType = mkOption {
        type = str;
        default = "";
      };
      device = mkOption {
        type = str;
        default = "";
      };
      label = mkOption {
        type = str;
        default = "";
      };
      options = mkOption {
        type = listOf str;
        default = [ ];
      };
    };
  };
in
{
  options.fs = {
    btrfs = {
      device = mkOption {
        type = types.str;
        default = "";
        description = ''
          Parition uuid for btrfs.
        '';
      };

      label = mkOption {
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
      type = types.attrsOf (types.submodule volumesMap);
      default = { };
      example = {
        "/" = {
          fsType = "ext4";
          device = "uuid";
          label = "label";
          options = [ ];
        };
      };

      description = ''
        mount filesystems.
      '';
    };

    swap = {
      device = mkOption {
        type = types.str;
        default = "";
        description = ''
          uuid of swap device
        '';
      };
      label = mkOption {
        type = types.str;
        default = "";
        description = ''
          label of swap device
        '';
      };
    };

    boot = {
      device = mkOption {
        type = types.str;
        default = "";
        description = ''
          Partition uuid of boot partition.
        '';
      };
      label = mkOption {
        type = types.str;
        default = "";
        description = ''
          Partition label of boot partition.
        '';
      };
    };

  };

  config =
    let
      btrfs =
        if (cfg.btrfs.device != "" || cfg.btrfs.label != "") then
          (mapAttrs
            (_: options: {
              device = mkIf (cfg.btrfs.device != "")
                "/dev/disk/by-label/${cfg.btrfs.device}";
              label = mkIf (cfg.btrfs.label != "") cfg.btrfs.label;
              fsType = "btrfs";
              options = options;
            })
            cfg.btrfs.volumes)
        else
          { };

      others = mapAttrs
        (_: params: {
          fsType = params.fsType;
          label = mkIf (params.label != "") params.label;
          device = mkIf (params.device != "") "/dev/disk/by-uuid/${params.device}";
          options = mkIf (params.options != [ ]) params.options;
        })
        cfg.normal.volumes;

      boot =
        if (cfg.boot.device != "" || cfg.boot.label != "") then {
          "/boot" = {
            device =
              mkIf (cfg.boot.device != "") "/dev/disk/by-uuid/${cfg.boot.device}";
            label = mkIf (cfg.boot.label != "") cfg.boot.label;
            fsType = "vfat";
          };
        } else
          { };
    in
    {
      fileSystems = btrfs // others // boot;

      swapDevices = mkIf (cfg.swap.device != "" || cfg.swap.label != "") [{
        device =
          mkIf (cfg.swap.device != "") "/dev/disk/by-uuid/${cfg.swap.device}";
        label = mkIf (cfg.swap.label != "") cfg.swap.label;
      }];

    };
}
