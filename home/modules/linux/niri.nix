{ config, lib, pkgs, ... }: {

  imports = [ ./waybar.nix ./hyprlock.nix ];
  xdg.configFile = {
    niri = {
      enable = true;
      source = ../../config/niri;
    };

    dunst = {
      enable = true;
      source = ../../config/dunst;
    };
  };

  home.packages = with pkgs; [
    qadwaitadecorations
    qadwaitadecorations-qt6

    swww

    # for screencast
    slurp
    grim
    satty
    (pkgs.writeScriptBin "screenshot"
      ''grim -g "$(slurp)" -t ppm - | satty --filename -'')
  ];
}
