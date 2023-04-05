{ config, lib, ... }:
with lib;

let cfg = config.fs.btrfs;
in {
  options.fs.btrfs = {
    device = mkOption {
      type = types.str;
      description = ''
        Parition UUID for btrfs.
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

  config = {
    fileSystems = mapAttrs (_: options: {
      device = cfg.device;
      fsType = "btrfs";
      options = options;
    }) cfg.volumes;
  };
}
