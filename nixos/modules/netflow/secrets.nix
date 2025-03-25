{ modules, ... }: {
  imports = with modules; [ secrets ];

  sops.secrets.clash = {
    mode = "0400";
    sopsFile = ./clash;
    format = "binary";
  };
}
