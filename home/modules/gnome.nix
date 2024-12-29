{ config, lib,... }: with lib; mkIf (config.nixpkgs.system == "x86_64-linux") {

  dconf.settings = {
    "org/gnome/shell" = {
      "disable-user-extensions" = false;
      "enabled-extensions" = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "kimpanel@kde.org"
        "gsconnect@andyholmes.github.io"
        "paperwm@paperwm.github.com"
        "quake-terminal@diegodario88.github.io"
        "display-brightness-ddcutil@themightydeity.github.com"
      ];
    };

    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    # app-switcher
    "org/gnome/shell/app-switcher" = { "current-workspace-only" = true; };

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
        "command" = "kitty";
        "name" = "kitty";
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

    "org/gnome/shell/extensions/display-brightness-ddcutil" = {
      show-all-slider = false;
    };

    # global keybindings
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Shift><Super>s" ];
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      toggle-application-view = [ "<Super>a" ];
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

    # paperwm
    "org/gnome/shell/extensions/paperwm" = {
      show-window-position-bar = false;
      show-workspace-indicator = false;
      vertical-margin = 5;
      vertical-margin-bottom = 5;
      selection-border-size = 5;
      horizontal-margin = 5;
      window-gap = 10;
    };
    "org/gnome/shell/extensions/paperwm/keybindings" = {
      barf-out-active = [ "<Shift><Super>l" ];
      center = [ "<Super>c" ];
      center-horizontally = [ "" ];
      switch-focus-mode = [ "" ];
      previous-workspace = [ "" ]; # will occupy 'super + grave'
      new-window = [ "<Super>n" ];
      slurp-in = [ "<Super>i" "<Shift><Super>h" ];
      move-down = [ "<Control><Super>k" ];
      move-left = [ "<Control><Super>h" ];
      move-right = [ "<Control><Super>l" ];
      move-up = [ "<Control><Super>k" ];
      switch-global-down = [ "<Super>j" ];
      switch-global-left = [ "<Super>h" ];
      switch-global-right = [ "<Super>l" ];
      switch-global-up = [ "<Super>k" ];
      cycle-width = [ "<Super>a" ];
      cycle-width-backwards = [ "<Shift><Super>a" ];
      toggle-maximize-width = [ "<Super>m" ];
      toggle-scratch = [ "<Super>f" ];
      toggle-scratch-layer = [ "<Shift><Super>f" ];
    };

    "org/gnome/shell/extensions/quake-terminal" = {
      always-on-top = true;
      render-on-current-monitor = true;
      terminal-id = "kitty.desktop";
      terminal-shortcut = [ "<Super>grave" ];
    };

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
