{ pkgs, ... }: {
  xdg.configFile = {
    ghostty = {
      enable = true;
      source = ../config/ghostty;
    };
  };
}
