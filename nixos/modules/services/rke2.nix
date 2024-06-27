{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.services.rke2;
  canalConfig = pkgs.writeTextFile {
    name = "canalConfig.yaml";
    text = ''
      ---
      apiVersion: helm.cattle.io/v1
      kind: HelmChartConfig
      metadata:
        name: rke2-canal
        namespace: kube-system
      spec:
        valuesContent: |-
          flannel:
            iface: "${cfg.iface}"'';
  };
  nginxConfig = pkgs.writeTextFile {
    name = "rke2-ingress-nginx-config.yaml";
    text = ''
      apiVersion: helm.cattle.io/v1
      kind: HelmChartConfig
      metadata:
        name: rke2-ingress-nginx
        namespace: kube-system
      spec:
        valuesContent: |-
          controller:
            allowSnippetAnnotations: true'';
  };
in
{ }
