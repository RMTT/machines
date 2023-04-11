{ pkgs, plasma-manager, ... }: {

  imports = [
    ./modules/shell.nix
    ./modules/alacritty.nix
    ./modules/neovim.nix
    ./modules/plasma.nix
    plasma-manager
  ];

  home.stateVersion = "23.05";

  # additional packages
  home.packages = with pkgs; [ exa zoom-us slack jetbrains.idea-community ];

  # configure git
  programs.git = {
    enable = true;
    userName = "RMT";
    userEmail = "d.rong@outlook.com";
    signing = {
      signByDefault = true;
      key = "407C5B126B1A1895";
    };
    extraConfig = {
      init.defaultBranch = "main";
      credential."https://github.com".helper =
        "!/usr/bin/env gh auth git-credential";
      credential."https://gist.github.com".helper =
        "!/usr/bin/env gh auth git-credential";
    };
  };

  # configure gpg
  programs.gpg = {
    enable = true;
    scdaemonSettings = { disable-ccid = true; };
  };
  # enable gpg agent
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryFlavor = "qt";
    enableExtraSocket = true;
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

  # firefox related
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = ''
        #TabsToolbar
        {
            visibility: collapse;
        }
      '';
    };
  };
}
