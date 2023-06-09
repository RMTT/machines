{ pkgs, ... }: {
  imports = [ ./desktop.nix ];
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # desktop apps
    environment.systemPackages = with pkgs; [
      # plasma related
      libsForQt5.bismuth
      libsForQt5.yakuake
      xclip
    ];

  };
}
