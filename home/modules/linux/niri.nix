{ config, lib, pkgs, ... }: {

  imports = [ ./waybar.nix ];
  xdg.configFile = {
    niri = {
      enable = true;
      source = ../../config/niri;
    };
  };

  home.packages = with pkgs; [ qadwaitadecorations qadwaitadecorations-qt6 ];
}
