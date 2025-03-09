{ modules, ... }: {
  imports = with modules; [ secrets ];
  sops.secrets.aronet = {
    mode = "0400";
    sopsFile = ./aronet;
    format = "binary";
  };
}
