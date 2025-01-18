{ pkgs, ... }: {
  home.packages = with pkgs; [ playerctl pavucontrol ddcui ];
  programs.waybar = {
    enable = true;
    settings.main = {
      "layer" = "top";
      "position" = "top";
      "modules-left" = [ "niri/workspaces" "niri/window" ];
      "modules-center" = [ "custom/music" ];
      "modules-right" = [
        "pulseaudio"
        "upower"
        "custom/brightness"
        "cpu"
        "battery"
        "clock"
        "tray"
        "custom/lock"
      ];
      "niri/workspaces" = {
        "disable-scroll" = true;
        "sort-by-name" = true;
        "format" = " {icon} ";
        "format-icons" = { "default" = ""; };
      };
      "niri/window" = {
        "icon" = true;
        "max-length" = 30;
      };
      "upower" = {
        format = "";
        "hide-if-empty" = true;
        "tooltip" = true;
      };
      "cpu" = { format = " {usage}%"; };
      "tray" = {
        "icon-size" = 20;
        "spacing" = 4;
      };
      "custom/music" = {
        "format" = "  {}";
        "escape" = true;
        "interval" = 5;
        "tooltip" = false;
        "exec" = "playerctl metadata --format='{{ title }}'";
        "on-click" = "playerctl play-pause";
        "max-length" = 25;
      };
      "custom/brightness" = {
        "exec" =
          "ddcutil getvcp 10 -t | perl -nE 'if (/ C (\\d+) /) { say $1; }'";
        "exec-if" = "sleep 1";
        "format" = "{icon} {}%";
        "format-icons" = [ "" ];
        "interval" = "once";
        "on-scroll-up" = "ddcutil setvcp 10 + 10";
        "on-scroll-down" = "ddcutil setvcp 10 - 10";
        "on-click" = "ddcui";
      };
      "clock" = {
        "timezone" = "Asia/Shanghai";
        "tooltip-format" = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
        "format-alt" = " {:%d/%m/%Y}";
        "format" = " {:%H:%M}";
      };
      "battery" = {
        "states" = {
          "warning" = 30;
          "critical" = 15;
        };
        "format" = "{icon}";
        "format-charging" = "";
        "format-plugged" = "";
        "format-alt" = "{icon}";
        "format-icons" = [ "" "" "" "" "" "" "" "" "" "" "" "" ];
      };
      "pulseaudio" = {
        "format" = "{icon} {volume}%";
        "format-muted" = "";
        "format-icons" = { "default" = [ "" "" " " ]; };
        "on-click" = "pavucontrol";
      };
      "custom/lock" = {
        "tooltip" = false;
        "on-click" = "hyprlock";
        "format" = "";
      };
    };
    # https://github.com/catppuccin/waybar/blob/main/themes/mocha.css
    style = ''
      @define-color rosewater #f5e0dc;
      @define-color flamingo #f2cdcd;
      @define-color pink #f5c2e7;
      @define-color mauve #cba6f7;
      @define-color red #f38ba8;
      @define-color maroon #eba0ac;
      @define-color peach #fab387;
      @define-color yellow #f9e2af;
      @define-color green #a6e3a1;
      @define-color teal #94e2d5;
      @define-color sky #89dceb;
      @define-color sapphire #74c7ec;
      @define-color blue #89b4fa;
      @define-color lavender #b4befe;
      @define-color text #cdd6f4;
      @define-color subtext1 #bac2de;
      @define-color subtext0 #a6adc8;
      @define-color overlay2 #9399b2;
      @define-color overlay1 #7f849c;
      @define-color overlay0 #6c7086;
      @define-color surface2 #585b70;
      @define-color surface1 #45475a;
      @define-color surface0 #313244;
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;

      * {
        font-family: FiraCode Nerd Font;
        font-size: 14px;
        min-height: 0;
        margin: 1px 0px 0px 0;
      }

      #waybar {
        background: transparent;
        color: @text;
      }

      #workspaces {
        border-radius: 0rem 1rem 1rem 0rem;
        background-color: @surface0;
        margin-right: 1rem;
      }

      #workspaces button {
        color: @lavender;
        border-radius: 1rem;
        padding: 0.4rem;
      }

      #workspaces button.active {
        color: @sky;
        border-radius: 1rem;
      }

      #workspaces button:hover {
        color: @sapphire;
        border-radius: 1rem;
      }

      #window {
        border-radius: 1rem;
        background-color: @surface0;
      }

      window#waybar.empty #window {
        background:none;
      }

      #custom-music,
      #workspaces,
      #window,
      #upower,
      #cpu,
      #tray,
      #custom-brightness,
      #clock,
      #battery,
      #pulseaudio,
      #custom-lock,
      #custom-power {
        background-color: @surface0;
        padding: 0.5rem 1rem;
      }

      #clock {
        color: @blue;
        border-radius: 0px 1rem 1rem 0px;
        margin-right: 1rem;
      }

      #battery {
        color: @green;
      }

      #battery.charging {
        color: @green;
      }

      #battery.warning:not(.charging) {
        color: @red;
      }

      #custom-brightness {
        color: @yellow;
      }

      #custom-brightness, #battery {
          border-radius: 0;
      }

      #pulseaudio {
        color: @maroon;
        border-radius: 1rem 0px 0px 1rem;
        margin-left: 1rem;
      }

      #custom-music {
        color: @mauve;
        border-radius: 1rem;
        margin-right: 1rem;
        margin-left: 1rem;
      }

      #custom-lock {
          border-radius: 1rem 0px 0px 1rem;
          color: @lavender;
      }

      #custom-power {
          margin-right: 1rem;
          border-radius: 0px 1rem 1rem 0px;
          color: @red;
      }

      #tray {
        margin-right: 1rem;
        border-radius: 1rem;
      }
    '';
  };
}
