{ modules, ... }: {

  imports = with modules; [ secrets ];

  sops.secrets.wg-private = {
    mode = "0400";
    sopsFile = ./wg.key;
    format = "binary";
  };

  sops.secrets.ups_pass = {
    mode = "0400";
    sopsFile = ./ups_pass;
    format = "binary";
  };

  sops.secrets.smtp-pass = { mode = "644"; };

  sops.secrets.godel-private = {
    mode = "0400";
    sopsFile = ./godel.key;
    format = "binary";
  };

  sops.secrets.header = {
    mode = "0400";
    sopsFile = ./header;
    format = "binary";
  };

  sops.secrets.gravity-private = {
    mode = "0400";
    sopsFile = ./gravity.key;
    format = "binary";
  };

  sops.secrets.aronet = {
    mode = "0400";
    sopsFile = ./aronet;
    format = "binary";
  };
}
