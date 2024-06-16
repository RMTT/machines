{ pkgs, ... }: {

  imports = [
		./modules/base.nix
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
  programs.gitui = {
    enable = true;
    keyConfig = ''
      (
          open_help: Some(( code: F(1), modifiers: "")),

          move_left: Some(( code: Char('h'), modifiers: "")),
          move_right: Some(( code: Char('l'), modifiers: "")),
          move_up: Some(( code: Char('k'), modifiers: "")),
          move_down: Some(( code: Char('j'), modifiers: "")),

          popup_up: Some(( code: Char('p'), modifiers: "CONTROL")),
          popup_down: Some(( code: Char('n'), modifiers: "CONTROL")),
          page_up: Some(( code: Char('b'), modifiers: "CONTROL")),
          page_down: Some(( code: Char('f'), modifiers: "CONTROL")),
          home: Some(( code: Char('g'), modifiers: "")),
          end: Some(( code: Char('G'), modifiers: "SHIFT")),
          shift_up: Some(( code: Char('K'), modifiers: "SHIFT")),
          shift_down: Some(( code: Char('J'), modifiers: "SHIFT")),

          edit_file: Some(( code: Char('I'), modifiers: "SHIFT")),

          status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),

          diff_reset_lines: Some(( code: Char('u'), modifiers: "")),
          diff_stage_lines: Some(( code: Char('s'), modifiers: "")),

          stashing_save: Some(( code: Char('w'), modifiers: "")),
          stashing_toggle_index: Some(( code: Char('m'), modifiers: "")),

          stash_open: Some(( code: Char('l'), modifiers: "")),

          abort_merge: Some(( code: Char('M'), modifiers: "SHIFT")),
      )
            			'';
    theme = ''
      (
          selected_tab: Some("Reset"),
          command_fg: Some("#cdd6f4"),
          selection_bg: Some("#585b70"),
          selection_fg: Some("#cdd6f4"),
          cmdbar_bg: Some("#181825"),
          cmdbar_extra_lines_bg: Some("#181825"),
          disabled_fg: Some("#7f849c"),
          diff_line_add: Some("#a6e3a1"),
          diff_line_delete: Some("#f38ba8"),
          diff_file_added: Some("#a6e3a1"),
          diff_file_removed: Some("#eba0ac"),
          diff_file_moved: Some("#cba6f7"),
          diff_file_modified: Some("#fab387"),
          commit_hash: Some("#b4befe"),
          commit_time: Some("#bac2de"),
          commit_author: Some("#74c7ec"),
          danger_fg: Some("#f38ba8"),
          push_gauge_bg: Some("#89b4fa"),
          push_gauge_fg: Some("#1e1e2e"),
          tag_fg: Some("#f5e0dc"),
          branch_fg: Some("#94e2d5")
      )
            			'';
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
