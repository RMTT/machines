{ pkgs, config, lib, ... }:
let cfg = config.desktop;
in with lib; {
  options = {
    desktop.gdm.scale = lib.mkOption {
      type = types.int;
      default = 1;
      description = "GDM scale factor";
    };

    desktop.gdm.avatar = lib.mkOption {
      type = types.str;
      default = "";
      description = "user which need set $HOME/.face to GDM avatar";
    };
  };

  config = {
    security.rtkit.enable = true;

    # many gtk apps need dconf
    programs.dconf.enable = true;

    # desktop apps
    environment.systemPackages = with pkgs; [
      firefox
      telegram-desktop
      nextcloud-client
      element-desktop
      zotero
      anki
      alacritty
      tela-icon-theme
      bitwarden
      yubikey-manager-qt
      solaar
      libreoffice-fresh
      obsidian
      virt-manager
      ownpkgs.zoom-us
      jetbrains.idea-community
    ];

    # fonts
    fonts.fontDir.enable = true;
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
      noto-fonts
      sarasa-gothic
      joypixels
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
    fonts.fontconfig = {
      allowBitmaps = false;
      defaultFonts = {
        emoji = [ "JoyPixels" ];
        serif = [
          "Sarasa Mono Slab SC"
          "Sarasa Mono Slab TC"
          "Sarasa Mono Slab J"
          "Sarasa Mono Slab K"
        ];
        sansSerif =
          [ "Sarasa UI SC" "Sarasa UI TC" "Sarasa UI J" "Sarasa UI K" ];
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

    # enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluez;
    hardware.bluetooth.settings = {
      General = {
        Experimental = true;
        KernelExperimental = true;
      };
    };

    # enable logitech
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true;

    # set gdm avatar
    boot.postBootCommands = mkIf (cfg.gdm.avatar != "") (let
      gdm_user_conf = ''
        [User]
        Icon=/home/${cfg.gdm.avatar}/.face
        SystemAccount=false
      '';
    in ''
      echo '${gdm_user_conf}' > /var/lib/AccountsService/users/${cfg.gdm.avatar}
    '');
  };
}
