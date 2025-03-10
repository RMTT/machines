{ modules, ... }: {
  imports = with modules; [ secrets ];
  sops.secrets.gravity-private = {
    mode = "0400";
    sopsFile = ./gravity.key;
    format = "binary";
  };

  sops.secrets.header = {
    mode = "0400";
    sopsFile = ./header;
    format = "binary";
  };

  sops.secrets.wg = {
    mode = "0400";
    sopsFile = ./wg.key;
    format = "binary";
  };
}
