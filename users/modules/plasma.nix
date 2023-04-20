{ plasma-manager, ... }: {
  imports = [ plasma-manager ];
  config = {
    programs.plasma = {
      enable = true;
      workspace.clickItemTo = "select";

      shortcuts = {
        "bismuth"."decrease_master_size" = "Meta+Ctrl+H";
        "bismuth"."focus_bottom_window" = "Meta+J";
        "bismuth"."focus_left_window" = "Meta+H";
        "bismuth"."focus_next_window" = "Meta+N";
        "bismuth"."focus_prev_window" = "Meta+P";
        "bismuth"."focus_right_window" = "Meta+L";
        "bismuth"."focus_upper_window" = "Meta+K";
        "bismuth"."increase_master_size" = "Meta+Ctrl+L";
        "bismuth"."move_window_to_left_pos" = "Meta+Shift+H";
        "bismuth"."move_window_to_right_pos" = "Meta+Shift+L";
        "bismuth"."next_layout" = "Meta+Space";
        "bismuth"."push_window_to_master" = "Meta+Shift+M";
        "bismuth"."rotate" = "Meta+Shift+R";
        "bismuth"."toggle_float_layout" = "Meta+Shift+F";
        "bismuth"."toggle_window_floating" = "Meta+F";

        "kwin"."Show Desktop" = "Meta+D";
        "kwin"."Switch to Desktop 1" = "Meta+1";
        "kwin"."Switch to Desktop 2" = "Meta+2";
        "kwin"."Switch to Desktop 3" = "Meta+3";
        "kwin"."Switch to Desktop 4" = "Meta+4";
        "kwin"."Window Close" = [ "Alt+F4" "Meta+Shift+C" ];
        "kwin"."Window Maximize" = "Meta+M";
        "kwin"."Window to Desktop 1" = "Meta+!";
        "kwin"."Window to Desktop 2" = "Meta+@";
        "kwin"."Window to Desktop 3" = "Meta+#";
        "kwin"."Window to Desktop 4" = "Meta+$";

        "org.kde.krunner.desktop"."_launch" = [ "Meta+R" "Search" ];

        "org.kde.spectacle.desktop"."RectangularRegionScreenShot" =
          "Meta+Shift+S";
      };

      files."kwinrc"."Desktops" = {
        "Id_1" = "ab85507c-da45-4238-9e40-0929234bf65d";
        "Id_2" = "85730966-d1a9-4824-a069-140988bacd0d";
        "Id_3" = "f35dbfc9-46bb-4fc5-9aea-2138847ce4bd";
        "Id_4" = "b0a5cee1-3a57-4fbc-8321-080cdbacb14b";
        "Name_1" = "Daily";
        "Name_2" = "Browser";
        "Name_3" = "Code";
        "Name_4" = "Game";
        "Number" = 4;
        "Rows" = 1;
      };

      files."kwinrc"."Plugins"."bismuthEnabled" = true;
      files."kwinrc"."Script-bismuth"."floatingClass" =
        "Wine,telegram-desktop,slack,yesplaymusic,discord,jetbrains-toolbox,Wine,GoldenDict,netease-cloud-music,tim.exe,wechat.exe,qq.exe,feeluown,icalingua,qq,QQ,virt-manager,looking-glass-client,weixin,netease-cloud-music-gtk4,dropdown,zoom";
    };
  };
}
