{ ... }: {
  sops.defaultSopsFile = ./keys.yaml;
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.age.keyFile = "/var/lib/sops-nix/age";
  sops.age.generateKey = false;
}
