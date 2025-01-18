{ pkgs, ... }: {
  home.packages = [ pkgs.hyprlock ];
  xdg.configFile."hypr" = {
    enable = true;
    source = ../../config/hypr;
  };
  home.file.".face" = { source = ../../assets/face.jpg; };
  home.file.".background" = { source = ../../assets/background.jpg; };
}
