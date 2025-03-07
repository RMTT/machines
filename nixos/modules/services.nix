{ ... }: {
  imports = [
    ./services/clash.nix
    ./services/pppoe.nix
    ./services/rke2.nix
    ./services/derper.nix
    ./services/udp2raw.nix
    ./services/socat.nix
    ./services/aronet.nix
  ];
}
