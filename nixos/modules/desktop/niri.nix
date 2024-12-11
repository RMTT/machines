{ pkgs, config, lib, ... }:
let cfg = config.desktop.niri;
in with lib; {

  options = { desktop.niri.enable = mkEnableOption "enable niri"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      niri
      gnome-keyring
      fuzzel
      hyprlock
      kdePackages.breeze
      kdePackages.breeze-gtk
      kitty
      alacritty
      xwayland-satellite
      nautilus
      wlsunset
      gammastep
    ];

    services.displayManager.sessionPackages = with pkgs; [ niri ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };
  };
}
