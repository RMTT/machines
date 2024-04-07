{ modules, ... }: {

  imports =
    with modules; [ secrets ];

  sops.secrets.wg-private = {
    owner = "systemd-network";
    mode = "0400";
    sopsFile = ./secrets/wg-private.key;
    format = "binary";
  };

  sops.secrets.ups_pass = {
    mode = "0400";
    sopsFile = ./secrets/ups_pass;
    format = "binary";
  };

  sops.secrets.zoho-pass = { mode = "644"; };

  sops.secrets.rke2 = {
    sopsFile = ./secrets/rke2-config;
    format = "binary";
  };
}
