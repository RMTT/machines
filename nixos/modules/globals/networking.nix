# global configurations
{ ... }:
{
  networking.extraHosts = builtins.readFile ./hosts;
  networking.firewall = {
    trustedSubnets = {
      ipv4 = [
        "192.168.6.1/24" # local net of home
        "192.168.128.0/24" # local net of my infra
      ];
    };


    allowedUDPPorts = [
      68 # DHCP and wireguard
      67 # DHCP and wireguard
      5201 # for iperf
    ];
    allowedTCPPorts = [
      5201 # for iperf
      6696 # for babel protocol
    ];
  };
}
