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
  ];

  system.stateVersion = "23.05";

  # set filesystems mount
  fs.normal.volumes = {
    "/" = {
      device = "1b1fb67b-6432-4ea5-bec4-89ee49e1498f";
      fsType = "ext4";
    };
  };
  fs.boot.device = "A433-095D";

  hardware.cpu.intel.updateMicrocode = true;

  base.gl.enable = true;

  # default shell
  users.users.mt.shell = pkgs.zsh;

  environment.variables = { NIXOS_OZONE_WL = "1"; };

  programs.clash-verge = {
    package = pkgs.fresh.clash-verge-rev;
    enable = true;
    tunMode = true;
  };
}
