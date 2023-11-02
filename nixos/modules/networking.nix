{ ... }:
let local_subnet = "192.168.6.1/24";
in {
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;
    extraInputRules = "ip saddr ${local_subnet} accept";
    checkReversePath = "loose";
  };
  networking.firewall.allowedUDPPorts = [ 68 67 ]; # DHCP
}
