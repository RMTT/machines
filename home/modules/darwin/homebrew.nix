{ config, lib, ... }:
with lib;
mkIf (config.nixpkgs.system == "aarch64-darwin") (let
  taps = [ ];

  brews = [ "koekeishiya/formulae/skhd" "kubernetes-cli" ];

  casks = [
    "nextcloud"
    "obsidian"
    "telegram"
    "kitty"
    "tailscale"
    "wechat"
    "iterm2" # for drop-down term(via hotkey profile)
    "kicad"
    "PlayCover/playcover/playcover-community"
    "zotero"
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
