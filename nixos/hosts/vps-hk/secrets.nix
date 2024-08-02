{ modules, ... }: {

  imports =
    with modules; [ secrets ];

  sops.secrets.wg-private = {
    owner = "systemd-network";
    mode = "0400";
    sopsFile = ./secrets/wg-private.key;
    format = "binary";
  };

  sops.secrets.k3s_token = {
    sopsFile = ./secrets/k3s_token;
    format = "binary";
  };

  sops.secrets.udp2raw = {
    mode = "0400";
    sopsFile = ./secrets/udp2raw;
    format = "binary";
  };
}
