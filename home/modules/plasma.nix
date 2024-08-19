{ ... }: {
  programs.plasma = {
    enable = true;
    workspace = {
      clickItemTo = "select";
      theme = "breeze-dark";
    };
    shortcuts = {
      "kitty.desktop"."New" = "Meta+Return";
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";
      "kwin"."Window Close" = [ "Alt+F4" "Meta+Shift+C" ];
      "kwin"."Window Maximize" = "Meta+M";
      "kwin"."Window Fullscreen" = [ "Meta+F" ];
      "kwin"."Window to Desktop 1" = "Meta+!";
      "kwin"."Window to Desktop 2" = "Meta+@";
      "kwin"."Window to Desktop 3" = "Meta+#";
      "kwin"."Window to Desktop 4" = "Meta+$";
      "org.kde.dolphin.desktop"."_launch" = "Meta+E";
      "org.kde.krunner.desktop"."_launch" = [ "Meta+R" "Search" ];
      "services/org.kde.spectacle.desktop"."RecordRegion" = "Meta+Shift+R";
      "org.kde.spectacle.desktop"."RectangularRegionScreenShot" =
        "Meta+Shift+S";
      "yakuake"."toggle-window-state" = [ "F12" "Meta+`" ];
    };
    configFile = {
      "kwinrc"."Desktops"."Id_1" = "ab85507c-da45-4238-9e40-0929234bf65d";
      "kwinrc"."Desktops"."Id_2" = "85730966-d1a9-4824-a069-140988bacd0d";
      "kwinrc"."Desktops"."Id_3" = "f35dbfc9-46bb-4fc5-9aea-2138847ce4bd";
      "kwinrc"."Desktops"."Id_4" = "b0a5cee1-3a57-4fbc-8321-080cdbacb14b";
      "kwinrc"."Desktops"."Name_1" = "Daily";
      "kwinrc"."Desktops"."Name_2" = "Browser";
      "kwinrc"."Desktops"."Name_3" = "Code";
      "kwinrc"."Desktops"."Name_4" = "Game";
      "kwinrc"."Desktops"."Number" = 4;
      "kwinrc"."Desktops"."Rows" = 1;

      "kdeglobals"."General"."BrowserApplication" = "firefox.desktop";
      "kdeglobals"."General"."TerminalApplication" = "alacritty";
      "kdeglobals"."General"."TerminalService" = "Alacritty.desktop";

      "kdeglobals"."General"."fixed" =
        "Sarasa Mono Slab SC,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."General"."font" = "Sarasa Gothic SC,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."General"."menuFont" =
        "Sarasa UI SC,10,-1,5,63,0,0,0,0,0,Semibold";
      "kdeglobals"."General"."smallestReadableFont" =
        "Sarasa Gothic SC,8,-1,5,50,0,0,0,0,0";
      "kdeglobals"."General"."toolBarFont" =
        "Sarasa UI SC,10,-1,5,50,0,0,0,0,0";
    };
  };

}
