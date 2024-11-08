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
  };
}
