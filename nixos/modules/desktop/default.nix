{ lib, pkgs, config, ... }: {
  imports = [
    ./desktop.nix
    ./pipewire.nix
    ./plasma.nix
    ./niri.nix
  ];

  config = {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ fxlinuxprint ];
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.systemPackages = [ pkgs.catppuccin-sddm ];
    services.displayManager.sddm = {
      package = lib.mkForce pkgs.kdePackages.sddm;
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha";
    };
  };
}
