{ lib, pkgs, ... }:
with lib; {
  imports = [ ./homebrew.nix ./homebrew.nix ./skhd.nix ];

  config = {
    programs.home-manager.enable = lib.mkForce false;

    home.packages = with pkgs; [ nerd-fonts.fira-code ];
  };
}
