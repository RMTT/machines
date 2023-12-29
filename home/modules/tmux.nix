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
in
{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    clock24 = true;
    extraConfig = ''
                        			set -s default-terminal 'screen-256color'

            									unbind-key C-b
            									set-option -g prefix C-x
            									bind-key C-x send-prefix

                        			bind -T copy-mode-vi v send -X begin-selection
                              bind -T copy-mode-vi C-v send -X rectangle-toggle
                              bind -T copy-mode-vi y send -X copy-selection-and-cancel
                              bind -T copy-mode-vi Escape send -X cancel
                              bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - | wl-copy"

                        			bind -n M-H select-pane -L
                              bind -n M-L select-pane -R
                              bind -n M-K select-pane -U
      												bind -n M-J select-pane -D

                        			bind -n M-P previous-window
                              bind -n M-N next-window

      												set-option -g status-interval 5
      												set-option -g automatic-rename on
      												set-option -g automatic-rename-format '#{b:pane_current_path}'

                        			set -sg escape-time 0

                  						set -g @plugin "nordtheme/tmux"
    '';
    plugins = [ nord-tmux ];
  };
}
