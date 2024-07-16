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
      wl-clipboard
			wayland-utils
      kdePackages.sddm-kcm
    ];

    programs.kdeconnect.enable = true;
  };
}
