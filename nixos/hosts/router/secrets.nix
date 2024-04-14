{ modules, ... }: {

  imports =
    with modules; [ secrets ];

  sops.secrets.wg-private = {
    owner = "systemd-network";
    mode = "0400";
    sopsFile = ./secrets/wg-private.key;
    format = "binary";
  };

  sops.secrets.udp2raw = {
    mode = "0400";
    sopsFile = ./secrets/udp2raw;
    format = "binary";
  };

  sops.secrets.ups_pass = {
    mode = "0400";
    sopsFile = ./secrets/ups_pass;
    format = "binary";
  };
}
