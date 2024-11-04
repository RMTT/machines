{ pkgs, ... }: {
  imports = [ ./desktop.nix ];
  config = {
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # desktop apps
    environment.systemPackages = with pkgs; [
      # plasma related
      kdePackages.yakuake
      kdePackages.filelight
			kdePackages.isoimagewriter
      wl-clipboard
      wayland-utils
      kdePackages.sddm-kcm
      kdePackages.print-manager
      xdg-desktop-portal-gtk # for GTK/GNOME applications to correctly apply cursor themeing on Wayland.
    ];

    services.printing = {
      enable = true;
      drivers = with pkgs; [ fxlinuxprint ];
    };
    programs.kdeconnect.enable = true;
  };
}
