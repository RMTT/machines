# global configurations
{ ... }: {
  networking.extraHosts = builtins.readFile ./hosts;
  networking.firewall = {
    trustedSubnets = {
      ipv4 = [
        "192.168.6.1/24" # local net of home
        "192.168.128.0/24" # local net of my infra
      ];
    };

    allowedUDPPorts = [
      68 # DHCP
      67 # DHCP
      5201 # for iperf
      53 # for dns
    ];
    allowedTCPPorts = [
      5201 # for iperf
    ];
  };
}
