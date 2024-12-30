{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    font = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font Mono";
    };
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    settings = {
      disable_ligatures = "never";
      hide_window_decorations = "yes";
      macos_option_as_alt = "both";
      macos_quit_when_last_window_closed = "yes";
    };
  };
}
