{ modules, ... }: {
  imports = with modules; [ secrets ];

  sops.secrets.godel = {
    mode = "0400";
    sopsFile = ./private;
    format = "binary";
  };
  sops.secrets.k3s-token = {
    mode = "0400";
    sopsFile = ./k3s-token;
    format = "binary";
  };
}
