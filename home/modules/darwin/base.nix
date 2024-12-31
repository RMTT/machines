{ config, lib, pkgs, ... }:
with lib; {
  imports = [ ./homebrew.nix ];

  config = {
    home.homeDirectory = mkForce "/Users/${config.home.username}";
    programs.home-manager.enable = lib.mkForce false;

    home.packages = with pkgs; [ nerd-fonts.fira-code ];
  };
}
