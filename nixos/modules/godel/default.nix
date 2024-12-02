{ ... }: {
  # TODO: complete this module
  imports = [ ./strongswan.nix ];

  config = {
    networking.firewall.trustedSubnets.ipv4 = [
      # need pass pod id to let pod access api server which listend on the node-ip
      "10.42.0.0/16" # pod ip range
    ];
  };
}
