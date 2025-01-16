{ lib, pkgs, config, ... }: {
  imports =
    [ ./desktop.nix ./pipewire.nix ./plasma.nix ./gnome.nix ./niri.nix ];

  config = {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ fxlinuxprint ];
    };

    environment.systemPackages = with pkgs; [ ddcutil ];
    boot.kernelModules = [ "i2c-dev" ];
    services.udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "Sweet";
      extraPackages = with pkgs; [ sweet-nova ];
    };

    services.geoclue2 = {
      enable = true;
      geoProviderUrl = "https://beacondb.net/v1/geolocate";
    };
    services.avahi.enable = true;
  };
}
