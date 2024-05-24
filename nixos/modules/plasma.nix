{ pkgs, ... }: {
  imports = [ ./desktop.nix ];
  config = {
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.sessionVariables = {
      QT_AUTO_SCREEN_SCALE_FACTOR = "auto";
    };

    # desktop apps
    environment.systemPackages = with pkgs; [
      # plasma related
      kdePackages.yakuake
      kdePackages.filelight
      wl-clipboard
      kdePackages.sddm-kcm
    ];

    programs.kdeconnect.enable = true;
  };
}
