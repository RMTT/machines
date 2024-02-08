{ modules, ... }: {

  imports =
    with modules; [ secrets ];

  sops.secrets.wg-private = {
    owner = "systemd-network";
    mode = "0400";
    sopsFile = ./secrets/wg-private.key;
    format = "binary";
  };

	sops.secrets.rke2 = {
		sopsFile = ./secrets/rke2-config;
		format = "binary";
	};
}
