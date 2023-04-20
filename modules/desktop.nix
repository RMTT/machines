{ pkgs, ownpkgs, ... }: {
  config = {
    # desktop apps
    environment.systemPackages = with pkgs; [
      firefox
      telegram-desktop
      alacritty
      tela-icon-theme
      bitwarden
      yubikey-manager-qt
      solaar
      libreoffice-fresh
      #      obsidian
    ];

    # fonts
    fonts.fontDir.enable = true;
    fonts.enableDefaultFonts = true;
    fonts.fonts = with pkgs; [
      noto-fonts
      sarasa-gothic
      noto-fonts-emoji
      ownpkgs.apple-fonts
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
    fonts.fontconfig = {
      allowBitmaps = false;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        serif = [
          "SF Pro Text"
          "Sarasa Mono Slab SC"
          "Sarasa Mono Slab TC"
          "Sarasa Mono Slab J"
          "Sarasa Mono Slab K"
        ];
        sansSerif = [
          "SF Pro"
          "Sarasa UI SC"
          "Sarasa UI TC"
          "Sarasa UI J"
          "Sarasa UI K"
        ];
        monospace = [
          "SF Mono"
          "FiraCode"
          "Sarasa Mono SC"
          "Sarasa Mono TC"
          "Sarasa Mono J"
          "Sarasa Mono K"
        ];
      };
    };

    # enable bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # enable logitech
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true;
  };
}
