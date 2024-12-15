/* The reason not using gnome as main DE:
   1. lack of system tray. tray extensions cannot show app icon except apps from flatpak(can fix, caused by qt theme).
   2. drop-down terminal experience sucks(ddterm and guake)
   3. input method experience sucks

   Advantages of gnome:
   1. configure reproducibility(compare to plasma, dconf is better than rc file)
   2. paperwm
*/
{ pkgs, lib, config, ... }:
let cfg = config.desktop.gnome;
in {
  options = with lib; { desktop.gnome.enable = mkEnableOption "enable gnome"; };
  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.gnome.enable = true;

    services.udev.packages = with pkgs; [ gnome-settings-daemon ];

    # desktop apps
    environment.systemPackages = with pkgs; [
      gnomeExtensions.appindicator
      gnomeExtensions.paperwm
      gnomeExtensions.kimpanel
      gnomeExtensions.quake-terminal
      gnomeExtensions.brightness-control-using-ddcutil
      gnome-tweaks
      gnome-themes-extra
      gnome-software
      adwaita-icon-theme
      dconf-editor
      wl-clipboard
      dconf2nix
    ];
    programs.kdeconnect = {
      #package = pkgs.gnomeExtensions.gsconnect;
      enable = true;
    };

    environment.gnome.excludePackages =
      (with pkgs; [ gnome-terminal epiphany tali iagno hitori atomix gedit ]);

    qt.style = "breeze";
    environment.sessionVariables = {
      XCURSOR_THEME = "Adwaita";
      QT_QPA_PLATFORM = "Wayland";
      XMODIFIERS = "@im=fcitx";
      QT_IM_MODULE = "fcitx";
      GTK_IM_MODULE = "fcitx";
    };
  };
}
