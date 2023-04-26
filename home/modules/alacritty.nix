{ ... }:
let configFile = ../config/alacritty.json;
in {
  programs.alacritty = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile configFile);
  };
}
