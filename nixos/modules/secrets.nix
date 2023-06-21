{ ... }: {
  sops.defaultSopsFile = ../../secrets/default.yaml;
  sops.age.sshKeyPaths = [ ];
  sops.age.keyFile = "/var/lib/sops-nix/age";
  sops.age.generateKey = false;

	sops.gnupg.sshKeyPaths = [];
}
