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
      gnomeExtensions.kimpanel
      gnome.gnome-themes-extra
      gnome.dconf-editor
      pop-launcher
      guake
      wl-clipboard
      libsForQt5.qt5ct
      adwaita-qt
    ];

    environment.gnome.excludePackages = (with pkgs.gnome; [
      gnome-terminal
      epiphany
      tali
      iagno
      hitori
      atomix
      gedit
    ]);

    environment.sessionVariables = {
      GUAKE_ENABLE_WAYLAND = "1";
      XCURSOR_THEME = "Adwaita";
    };
  };
}
