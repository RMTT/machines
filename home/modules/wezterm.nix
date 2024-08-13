{ ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = ''
      return dofile("${../config/wezterm/wezterm.lua}")
    '';
  };
}
