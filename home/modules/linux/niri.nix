{ config, lib, pkgs, ... }: {
  xdg.configFile = {
    niri = {
      enable = true;
      source = ../../config/niri;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "breeze_cursors";
    size = 24;
    package = pkgs.kdePackages.breeze-gtk;
  };
}
