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

  sops.secrets.godel-private = {
    mode = "0400";
    sopsFile = ./godel.key;
    format = "binary";
  };

  sops.secrets.wg = {
    mode = "0400";
    sopsFile = ./wg.key;
    format = "binary";
  };

  sops.secrets.k3s = {
    mode = "0400";
    sopsFile = ./k3s;
    format = "binary";
  };

  sops.secrets.aronet = {
    mode = "0400";
    sopsFile = ./aronet;
    format = "binary";
  };
}
