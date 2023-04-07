{ pkgs, ... }: {

  imports =
    [ ./modules/shell.nix ./modules/alacritty.nix ./modules/neovim.nix ];

  home.stateVersion = "23.05";

  # additional packages
  home.packages = with pkgs; [ exa zoom-us ];

  # configure git
  programs.git = {
    enable = true;
    userName = "RMT";
    userEmail = "d.rong@outlook.com";
    extraConfig = {
      init.defaultBranch = "main";
      credential."https://github.com".helper =
        "!/usr/bin/env gh auth git-credential";
      credential."https://gist.github.com".helper =
        "!/usr/bin/env gh auth git-credential";
    };
  };

  # enable gpg agent
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # direnv configuration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # configure gitui
  xdg.configFile.gitui = {
    source = ./modules/config/gitui;
    recursive = true;
  };
}
