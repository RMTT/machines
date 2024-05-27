{ config, ... }: {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "JoyPixels" ];
      serif = [
        "Sarasa Mono Slab SC"
        "Sarasa Mono Slab TC"
        "Sarasa Mono Slab J"
        "Sarasa Mono Slab K"
      ];
      sansSerif =
        [ "Sarasa UI SC" "Sarasa UI TC" "Sarasa UI J" "Sarasa UI K" "Noto Sans CJK SC" ];
      monospace =
        [ "Sarasa Mono SC" "Sarasa Mono TC" "Sarasa Mono J" "Sarasa Mono K" ];
    };
  };
}
