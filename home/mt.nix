{ pkgs, stateVersion, ownpkgs, ... }: {

  imports = [
    ./modules/shell.nix
    ./modules/alacritty.nix
    ./modules/neovim.nix
    ./modules/gnome.nix
    ./modules/tmux.nix
  ];

  home.stateVersion = stateVersion;

  # additional packages
  home.packages = with pkgs; [ ownpkgs.zoom-us jetbrains.idea-community ];

  # configure git
  programs.git = {
    enable = true;
    userName = "RMT";
    userEmail = "d.rong@outlook.com";
    signing = {
      signByDefault = true;
      key = "RMTTT";
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
    enableExtraSocket = true;
    enableZshIntegration = true;
    pinentryFlavor = "gnome3";
    extraConfig = "	allow-loopback-pinentry\n";
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
    source = ./config/gitui;
    recursive = true;
  };

  # firefox related
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "security.webauthn.ctap2" = true;
        "media.ffmpeg.vaapi.enabled" = true;
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
