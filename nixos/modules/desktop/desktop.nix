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
      element-desktop
      zotero
      anki
      tela-icon-theme
      bitwarden
      yubikey-manager-qt
      solaar
      virt-manager
      easyeffects
      motrix
      firefox
      xsettingsd
      vlc
      xorg.xrdb

      fresh.obsidian
      fresh.kicad
      fresh.nextcloud-client
      fresh.libreoffice-qt6
    ];
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
    services.flatpak.enable = true;

    # zoom will invoke "/usr/libexec/xdg-desktop-portal" for screen share
    systemd.tmpfiles.rules = [
      "L /usr/libexec/xdg-desktop-portal - - - - ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal"
    ];

    # fcitx5
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
          fcitx5-chinese-addons
          fcitx5-material-color
          fcitx5-pinyin-moegirl
          fcitx5-pinyin-zhwiki
        ];
      };
    };
    # fonts
    fonts.fontDir.enable = true;
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
      wqy_zenhei
      noto-fonts
      sarasa-gothic
      joypixels
      noto-fonts-emoji
      nerd-fonts.fira-code
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
        sansSerif = [
          "Sarasa UI SC"
          "Sarasa UI TC"
          "Sarasa UI J"
          "Sarasa UI K"
          "Noto Sans CJK SC"
        ];
        monospace =
          [ "Sarasa Mono SC" "Sarasa Mono TC" "Sarasa Mono J" "Sarasa Mono K" ];
      };
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };

    # enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluez;

    # enable logitech
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true;

    # key mapper
    services.kanata = {
      enable = true;
      keyboards.default = {
        config = ''
          (defsrc
            caps)

          (deflayermap (default-layer)
            caps esc)
        '';
      };
    };
  };
}
