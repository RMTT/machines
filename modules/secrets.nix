{ ... }: {
  sops.defaultSopsFile = ../secrets/default.yaml;
  sops.age.sshKeyPaths = [ ];
  sops.age.keyFile = "/var/lib/sops-nix/age";
  sops.age.generateKey = false;

  sops.secrets.cloudflare-ddns-domains = { };
  sops.secrets.cloudflare-zone-id = { };
  sops.secrets.cloudflare-token = { };
}
