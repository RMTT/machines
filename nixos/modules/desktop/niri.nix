{ pkgs, config, lib, ... }:
let cfg = config.desktop.niri;
in with lib; {

  options = { desktop.niri.enable = mkEnableOption "enable niri"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fresh.niri
      fuzzel
      hyprlock
      kitty
      alacritty
      xwayland-satellite
      wlsunset
      wl-clipboard-rs

      kdePackages.qtwayland
      libsForQt5.qt5.qtwayland

      networkmanagerapplet
      blueman
      dunst

      # apps
      nautilus
      seahorse
      loupe
      file-roller
      evince
      loupe
    ];

    #to use gnome apps
    services.gvfs.enable = true;
    services.gnome.gnome-keyring.enable = true;

    services.upower.enable = true;

    services.displayManager.sessionPackages = with pkgs.fresh; [ niri ];

    security.polkit.enable = true;
    security.pam.services.hyprlock = { };

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
