{ pkgs, lib, config, modules, ... }: {
  imports = with modules; [
    globals
    base
    fs
    networking
    plasma
    pipewire
    developments
    services
    docker
    wireguard
    godel
    gravity
  ];

  fileSystems = {
    "/".device = "/dev/hda1";
    "/data" = {
      device = "/dev/hda2";
      fsType = "ext3";
      options = [ "data=journal" ];
    };
    "/bigdisk".label = "bigdisk";
  };
}
