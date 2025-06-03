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

    fuzzel = {
      enable = true;
      source = ../../config/fuzzel;
    };
  };

  # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  home.packages = with pkgs; [
    qadwaitadecorations
    qadwaitadecorations-qt6

    swww # for wallpapaer

    # for screencast
    slurp
    grim
    satty
    (pkgs.writeScriptBin "screenshot"
      ''grim -g "$(slurp)" -t ppm - | satty --filename -'')
  ];
}
