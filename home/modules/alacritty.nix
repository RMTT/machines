{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "${pkgs.alacritty-theme}/catppuccin_mocha.toml" ];
      env = {
        TERM = "xterm-256color";
      };
      window = {
        decorations = "none";
        decorations_theme_variant = "Dark";
        dimensions = {
          columns = 90;
          lines = 30;
        };
      };
      font = {
        normal = {
          family = "FiraCode Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "FiraCode Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "FiraCode Nerd Font Mono";
          style = "Bold Italic";
        };
      };
      cursor = {
        style = {
          shape = "Beam";
          blinking = "Always";
        };
        vi_mode_style = {
          shape = "Block";
        };
      };
    };
  };
}
