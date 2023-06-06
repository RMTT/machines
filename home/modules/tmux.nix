{ pkgs, lib, ... }:
let
  nord-tmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "nord";
    version = "0.3";
    src = fetchGit {
      url = "https://github.com/nordtheme/tmux";
      ref = "develop";
      rev = "f7b6da07ab55fe32ee5f7d62da56d8e5ac691a92";
    };
  };
in {
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    clock24 = true;
    extraConfig = ''
            			set -s default-terminal 'screen-256color'

            			bind -T copy-mode-vi v send -X begin-selection
                  bind -T copy-mode-vi C-v send -X rectangle-toggle
                  bind -T copy-mode-vi y send -X copy-selection-and-cancel
                  bind -T copy-mode-vi Escape send -X cancel
                  bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - | wl-copy"

            			bind -n M-H select-pane -L
                  bind -n M-L select-pane -R
                  bind -n M-K select-pane -U
                  bind -n M-J select-pane -D

            			set -sg escape-time 0

      						set -g @plugin "nordtheme/tmux"
    '';
    plugins = [ nord-tmux ];
  };
}
