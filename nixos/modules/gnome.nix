{ pkgs, ... }: {
  imports = [ ./desktop.nix ];
  config = {
    qt = {
      enable = true;
      platformTheme = "qt5ct";
      style = "adwaita-dark";
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
      gnomeExtensions.quake-mode
      gnome.gnome-tweaks
      gnomeExtensions.kimpanel
      gnome.gnome-themes-extra
      gnome.adwaita-icon-theme
      gnome.dconf-editor
      gnome.gdm
      wl-clipboard
      qgnomeplatform-qt6
      qgnomeplatform
      adwaita-qt
      adwaita-qt6
    ];
    programs.kdeconnect = {
      package = pkgs.gnomeExtensions.gsconnect;
      enable = true;
    };

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
      XCURSOR_THEME = "Adwaita";
      QT_QPA_PLATFORM = "Wayland";
    };
  };
}
