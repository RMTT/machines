{ pkgs, config, lib, ... }:
let cfg = config.desktop.niri;
in with lib; {

  options = { desktop.niri.enable = mkEnableOption "enable niri"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fresh.niri
      gnome-keyring
      fuzzel
      hyprlock
      kitty
      alacritty
      xwayland-satellite
      nautilus
      wlsunset
      gammastep

      kdePackages.qtwayland
      libsForQt5.qt5.qtwayland

      networkmanagerapplet
      blueman
    ];

    services.displayManager.sessionPackages = with pkgs.fresh; [ niri ];
    services.geoclue2.enable = true;
    services.avahi.enable = true;

    programs.xwayland = {
      enable = true;
      package = pkgs.xwayland-satellite;
    };

    xdg.portal = {
      enable = true;
      configPackages = [ pkgs.fresh.niri ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };
  };
}
