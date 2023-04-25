{ pkgs, config, ownpkgs, lib, ... }:
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
    nixpkgs.config.permittedInsecurePackages = [ "electron-21.4.0" ];

    # many gtk apps need dconf
    programs.dconf.enable = true;

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
      obsidian
      virt-manager
      moonlight-qt
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
    services.blueman.enable = true;
    hardware.bluetooth.package = pkgs.bluezFull;

    # enable logitech
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true;

    # set gdm scale
    home-manager.users = mkIf (cfg.gdm.scale != 1) {
      gdm = { lib, stateVersion, ... }: {
        home.stateVersion = stateVersion;
        home.file.".cache/.keep".enable = lib.mkForce false;
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            scaling-factor = lib.hm.gvariant.mkUint32 2;
          };
        };
      };
    };

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
