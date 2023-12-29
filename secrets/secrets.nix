{ ... }: {
  sops.defaultSopsFile = ./keys.yaml;
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.age.keyFile = "/var/lib/sops-nix/age";
  sops.age.generateKey = false;

  sops.secrets.clash_config = {
    sopsFile = ./clash_config;
    format = "binary";
    mode = "644";
  };

}
