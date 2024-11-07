{ modules, ... }: {
  imports = with modules;[ secrets ];
  sops.secrets.ipsec-private = {
    mode = "0400";
    sopsFile = ./secrets/private.pem;
    format = "binary";
  };

  sops.secrets.header = {
    mode = "0400";
    sopsFile = ./secrets/header;
    format = "binary";
  };
}
