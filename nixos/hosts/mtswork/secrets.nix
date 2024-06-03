{ modules, ... }: {

  imports =
    with modules; [ secrets ];

  sops.secrets.myclash = {
    sopsFile = ./secrets/clash;
    format = "binary";
    mode = "644";
  };
}

