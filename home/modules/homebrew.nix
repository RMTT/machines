{ config, lib, ... }:
with lib;
mkIf (config.nixpkgs.system == "aarch64-darwin") (let
  taps = [ ];

  brews = [ "koekeishiya/formulae/skhd" ];

  casks = [
    "nextcloud"
    "obsidian"
    "telegram"
    "clash-verge-rev"
    "kitty"
    "tailscale"
    "wechat"
    "iterm2" # for drop-down term(via hotkey profile)
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
  };
})
