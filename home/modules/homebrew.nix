{ config, lib, ... }:
with lib;
mkIf (config.nixpkgs.system == "aarch64-darwin") (let
  taps = [ ];

  brews = [ ];

  casks = [
    "nextcloud"
    "obsidian"
    "telegram"
    "clash-verge-rev"
    "kitty"
    "tailscale"
  ];

in with lib; {
  home.sessionPath = [ "/opt/homebrew/bin" ];

  home.file.".Brewfile" = {
    text = (concatMapStrings (tap:
      ''tap "'' + tap + ''
        "
      ''

    ) taps) + (concatMapStrings (brew:
      ''brew "'' + brew + ''
        "
      ''

    ) brews) + (concatMapStrings (cask:
      ''cask "'' + cask + ''
        "
      ''

    ) casks);
    # onChange = ''
    #   /opt/homebrew/bin/brew bundle install --cleanup --no-upgrade --force --no-lock --global
    # '';
  };
})
