{ config, lib,... }: with lib; mkIf (config.nixpkgs.system == "x86_64-linux") {
  xdg.configFile = {
    niri = {
      enable = true;
      source = ../config/niri;
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
