{ lib, ... }: {

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/shell" = {
      "disable-user-extensions" = false;
      "enabled-extensions" = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "arcmenu@arcmenu.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        "kimpanel@kde.org"
        "pop-shell@system76.com"
      ];
    };

    # app-switcher
    "org/gnome/shell/app-switcher" = { "current-workspace-only" = true; };

    # arch menu
    "org/gnome/shell/extensions/arcmenu" = {
      "position-in-panel" = "Center";
      "runner-menu-custom-hotkey" = [ "<Super>r" ];
      "runner-menu-hotkey-type" = "Custom";
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

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
      {
        "binding" = "<Super>grave";
        "command" = "guake-toggle";
        "name" = "dropdown";
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

    # pop shell
    "org/gnome/shell/extensions/pop-shell" = {
      active-hint = true;
      active-hint-border-radius = mkUint32 2;
      fullscreen-launcher = true;
      gap-inner = mkUint32 2;
      gap-outer = mkUint32 2;
      log-level = mkUint32 1;
      mouse-cursor-focus-location = mkUint32 4;
      show-skip-taskbar = true;
      show-title = false;
      smart-gaps = true;
      snap-to-grid = true;
      tile-by-default = true;
      tile-enter = [ "<Super><Shift>Enter" ];
      toggle-floating = [ "<Super>f" ];
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
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      switch-input-source = [ "<Super>space" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      toggle-maximized = [ "<Super>m" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
      titlebar-font = "SF Compact Display 11";
      workspace-names = [ "Daily" "Browser" "Code" "Fun" ];
    };

    # guake related
    "apps/guake/keybindings/global" = { show-hide = "<Super>grave"; };

    # interface settings
    "org/gnome/desktop/interface" = {
      clock-show-date = true;
      color-scheme = "prefer-dark";
      cursor-theme = "Adwaita";
      document-font-name = "SF Pro Text 11";
      font-antialiasing = "rgba";
      font-hinting = "full";
      font-name = "SF Pro Rounded 10";
      gtk-theme = "Adwaita-dark";
      icon-theme = "Tela-blue-dark";
      monospace-font-name = "SF Mono 10";
    };

  };

}
