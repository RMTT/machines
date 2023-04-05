{ ... }: {
  networking.networkmanager.enable = true;
  networking.useDHCP = true;

  # enable firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
}
