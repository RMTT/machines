{ pkgs, config, lib, ... }:
let cfg = config.desktop;
in with lib; {
  options = { };

  config = {
    security.rtkit.enable = true;

    # many gtk apps need dconf
    programs.dconf.enable = true;

    # desktop apps
    environment.systemPackages = with pkgs; [
      telegram-desktop
      nextcloud-client
      element-desktop
      zotero
      anki
      tela-icon-theme
      bitwarden
      yubikey-manager-qt
      solaar
      libreoffice-fresh
      obsidian
      virt-manager
      zoom-us
      openconnect
      kicad
      easyeffects
    ];

    # fonts
    fonts.fontDir.enable = true;
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
      wqy_zenhei
      noto-fonts
      noto-fonts-cjk
      sarasa-gothic
      joypixels
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
    fonts.fontconfig = {
      cache32Bit = true;
      allowBitmaps = true;
      defaultFonts = {
        emoji = [ "JoyPixels" ];
        serif = [
          "Sarasa Mono Slab SC"
          "Sarasa Mono Slab TC"
          "Sarasa Mono Slab J"
          "Sarasa Mono Slab K"
        ];
        sansSerif =
          [ "Sarasa UI SC" "Sarasa UI TC" "Sarasa UI J" "Sarasa UI K" "Noto Sans CJK SC" ];
        monospace =
          [ "Sarasa Mono SC" "Sarasa Mono TC" "Sarasa Mono J" "Sarasa Mono K" ];
      };
    };

    # fcitx5
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-chinese-addons
      ];
    };

    xdg.portal.enable = true;

    # enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluez;

    # enable logitech
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true;

    services.input-remapper.enable = true;
    services.fwupd.enable = true;
  };
}
