{ lib, pkgs, ... }:
with lib; {
  imports = [ ./homebrew.nix ./homebrew.nix ./skhd.nix ];

  config = {
    programs.home-manager.enable = lib.mkForce false;

    home.packages = with pkgs; [
      nerd-fonts.fira-code
      sshuttle
      colima
      docker
      htop

      # dev tools
      autoconf
      automake
      glibtool
      pkg-config
      gettext
      perl
      gperf
      flex
      bison
      rustup
      bear

      (pkgs.python3.withPackages (python-pkgs: [ ]))
    ];
  };
}
