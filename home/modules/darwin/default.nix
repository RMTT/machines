{ lib, ... }:
with lib; {
  imports = [ ./homebrew.nix ./homebrew.nix ./skhd.nix ];

  config = {
    home.homeDirectory = mkForce "/Users/${config.home.username}";
    programs.home-manager.enable = lib.mkForce false;

    home.packages = with pkgs; [ nerd-fonts.fira-code ];
  };
}
