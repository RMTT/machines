{ ... }: {

  dconf.settings = {
    "org/gnome/shell" = {
      "disable-user-extensions" = false;
      "enabled-extensions" = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "arcmenu@arcmenu.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        "kimpanel@kde.org"
        "gsconnect@andyholmes.github.io"
        "quake-mode@repsac-by.github.com"
      ];
    };

    # app-switcher
    "org/gnome/shell/app-switcher" = { "current-workspace-only" = true; };

    # arch menu
    "org/gnome/shell/extensions/arcmenu" = {
      "position-in-panel" = "Center";
      "enable-standlone-runner-menu" = true;
      "runner-menu-custom-hotkey" = [ "<Super>r" ];
      "runner-menu-hotkey-type" = "Custom";
      "hide-overview-on-startup" = true;
    };

    # custom keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      "custom-keybindings" = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
      "screensaver" = [ "<Control><Alt>l" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        "binding" = "<Super>Return";
        "command" = "env XCURSOR_THEME=Adwaita alacritty";
        "name" = "alacritty";
      };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" =
      {
        binding = "<Super>e";
        command = "nautilus";
        name = "files";
      };

    # kim panel
    "org/gnome/shell/extensions/kimpanel" = {
      font = "Sarasa Mono Slab SC 11";
      vertical = false;
    };

    # global keybindings
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Shift><Super>s" ];
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      toggle-application-view = [ "<Super>a" ];
      toggle-overview = [ "<Super>s" ];
    };

    # wm related
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Shift><Super>c" ];
      maximize = "@as []";
      minimize = [ "<Control><Super>h" ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      switch-applications = [ "<Super>Tab" ];
      switch-applications-backward = [ "<Shift><Super>Tab" ];
      switch-group = [ "<Alt>grave" ];
      switch-group-backward = "@as []";
      switch-input-source = [ "<Super>space" ];
      switch-input-source-backward = [ "<Shift><Super>space" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
      toggle-maximized = [ "<Super>m" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
      titlebar-font = "Sarasa UI SC 10";
      workspace-names = [ "Daily" "Browser" "Code" "Fun" ];
    };

    # quake-mode related
    "com/github/repsac-by/quake-mode" = {
      quake-mode-always-on-top = false;
      quake-mode-focusout = true;
      quake-mode-height = 60;
      quake-mode-hide-from-overview = true;
      quake-mode-tray = true;
      quake-mode-width = 100;
    };

    "com/github/repsac-by/quake-mode/accelerators" = {
      quake-mode-accelerator-1 = [ "<Super>grave" ];
    };

    "com/github/repsac-by/quake-mode/apps" = { app-1 = "Alacritty.desktop"; };

    # interface settings
    "org/gnome/desktop/interface" = {
      clock-show-date = true;
      color-scheme = "prefer-dark";
      cursor-theme = "Adwaita";
      document-font-name = "Sarasa Fixed SC 11";
      font-antialiasing = "rgba";
      font-hinting = "full";
      font-name = "Sarasa UI SC 10";
      gtk-theme = "Adwaita-dark";
      icon-theme = "Tela-blue-dark";
      monospace-font-name = "Sarasa Mono SC 10";
    };

  };
}
