{ pkgs, config, lib, ... }:
let cfg = config.desktop.plasma;
in with lib; {
  options = { desktop.plasma.enable = mkEnableOption "enable plasma"; };
  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    # desktop apps
    environment.systemPackages = with pkgs; [
      # plasma related
      kdePackages.yakuake
      kdePackages.filelight
      kdePackages.isoimagewriter
      kdePackages.kconfig
      pkgs.kwin4-effect-geometry-change
      wl-clipboard
      wayland-utils
      kdePackages.sddm-kcm
      kdePackages.print-manager
      xdg-desktop-portal-gtk # for GTK/GNOME applications to correctly apply cursor themeing on Wayland.
    ];

    programs.kdeconnect.enable = true;
  };
}
