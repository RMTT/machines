{ ... }: {
  networking.networkmanager.enable = true;

  # enable firewall
  networking.firewall.enable = true;
}
