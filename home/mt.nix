{ pkgs, config, lib, system, ... }: {
  imports = [
    ./modules/base.nix
    ./modules/shell.nix
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/kitty.nix
    ./modules/plasma.nix
    ./modules/niri.nix
    ./modules/fonts.nix
    ./modules/gitui.nix
    ./modules/skhd.nix
    ./modules/tmux.nix

    # darwin modules
    (if (system == "aarch64-darwin") then ./modules/darwin else null)
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
    pinentryPackage = pkgs.pinentry-curses;
    extraConfig = "	allow-loopback-pinentry\n";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable =
    lib.mkIf (config.nixpkgs.system == "aarch64-darwin") (lib.mkForce false);

  # direnv configuration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        indent_style = "space";
        indent_size = 2;
      };
    };
  };
}
