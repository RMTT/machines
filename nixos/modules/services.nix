{ ... }: {
  imports = [
    ./services/cloudflare-ddns.nix
    ./services/split_flow.nix
    ./services/pppoe.nix
  ];
}
