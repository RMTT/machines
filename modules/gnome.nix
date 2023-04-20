{ pkgs, ... }: {
  imports = [ ./desktop.nix ];
  config = {
    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

    programs.dconf.enable = true;

    # desktop apps
    environment.systemPackages = with pkgs; [
      # gnome related
      gnomeExtensions.appindicator
      gnomeExtensions.arcmenu
      gnome.gnome-tweaks
      xdg-desktop-portal-gnome
      gnomeExtensions.customize-ibus
      guake
      wl-clipboard
      libsForQt5.qt5ct
      adwaita-qt
    ];

    # fcitx5
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-chinese-addons
      ];
    };

  };
}
