{ pkgs, ... }: {

  imports = [
    ./modules/shell.nix
    ./modules/alacritty.nix
    ./modules/neovim.nix
    ./modules/plasma.nix
    ./modules/tmux.nix
    ./modules/git.nix
    ./modules/fonts.nix
  ];
  home.stateVersion = "23.05";

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
    pinentryPackage = pkgs.pinentry-qt;
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

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        indent_style = "space";
        indent_size = 4;
      };
    };
  };

  # firefox related
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "security.webauthn.ctap2" = true;
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
