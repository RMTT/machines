{ pkgs, ownpkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.theme = "breeze";

  # configure SDDM
  services.xserver.displayManager.sddm.settings = {
    X11.ServerArguments = "-nolisten tcp -dpi 144";
    Theme.CursorTheme = "breeze_cursors";
  };

  # swap keys
  services.xserver.xkbOptions = "caps:escape";

  # desktop apps
  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    tdesktop
    alacritty
    tdrop
    libsForQt5.bismuth
    libsForQt5.xdg-desktop-portal-kde
    libsForQt5.kconfig
    tela-icon-theme
    bitwarden
    yubikey-manager-qt
    solaar
    libreoffice-fresh
    obsidian
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
    defaultFonts = {
      serif = [
        "New York"
        "Sarasa Mono Slab SC"
        "Sarasa Mono Slab TC"
        "Sarasa Mono Slab J"
        "Sarasa Mono Slab K"
      ];
      sansSerif =
        [ "SF Pro" "Sarasa UI SC" "Sarasa UI TC" "Sarasa UI J" "Sarasa UI K" ];
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

  # fcitx 5
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.enableRimeData = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-rime
      fcitx5-chinese-addons
    ];
  };

  # enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
