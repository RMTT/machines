{ ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = ''
			local wezterm = require 'wezterm'
			local config = wezterm.config_builder()

      config.color_scheme = "Catppuccin Mocha"
			config.xcursor_theme = "breeze_cursors"
			config.font = wezterm.font("FiraCode Nerd Font Mono")
			config.use_ime = true
			config.window_decorations = "NONE"
			config.hide_tab_bar_if_only_one_tab = true

			return config
      '';
  };
}
