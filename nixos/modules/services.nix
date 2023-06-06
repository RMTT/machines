{ ... }: {
  imports = [
    ./services/cloudflare-ddns.nix
    ./services/clash.nix
    ./services/pppoe.nix
  ];
}
