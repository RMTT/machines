{ modules, ... }: {
  imports = with modules; [ secrets ];

  sops.secrets.godel = {
    mode = "0400";
    sopsFile = ./private;
    format = "binary";
  };
}
