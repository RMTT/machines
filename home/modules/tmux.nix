{ pkgs, lib, ... }:
{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    clock24 = true;
    escapeTime = 0;
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
    '';
    plugins = with pkgs.tmuxPlugins; [{
      plugin = catppuccin;
      extraConfig = ''
        set -g @catppuccin_window_left_separator "█"
        set -g @catppuccin_window_right_separator "█ "
        set -g @catppuccin_window_number_position "right"
        set -g @catppuccin_window_middle_separator "  █"
        set -g @catppuccin_window_default_fill "number"
        set -g @catppuccin_window_current_fill "number"
        set -g @catppuccin_window_current_text "#{b:pane_current_path}"
        set -g @catppuccin_status_modules_right "application session date_time"
        set -g @catppuccin_status_left_separator  ""
        set -g @catppuccin_status_right_separator " "
        set -g @catppuccin_status_fill "all"
        set -g @catppuccin_status_connect_separator "yes"
          				'';
    }];
  };
}
