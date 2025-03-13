{ modules, ... }: {
  imports = with modules; [ secrets ];

  sops.secrets.grafana-token = {
    mode = "0400";
    sopsFile = ./grafana-token;
    format = "binary";
    owner = "prometheus";
  };
}
