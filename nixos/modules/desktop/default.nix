{ lib, pkgs, config, ... }: {
  imports =
    [ ./desktop.nix ./pipewire.nix ./plasma.nix ./gnome.nix ./niri.nix ];

  config = {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ fxlinuxprint ];
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    services.displayManager.ly = { enable = true; };
  };
}
