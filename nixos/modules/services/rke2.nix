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
{
  options = {
    services.rke2 = {
      enable = mkEnableOption "Enable rke2 server";
      role = mkOption {
        type = types.str;
        default = "agent";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.rke2;
      };
      params = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };

      configFile = mkOption {
        type = types.nullOr types.path;
        default = null;
      };

      iface = mkOption {
        type = types.str;
        default = "wg0";
      };
    };
  };
  config = {
    environment.systemPackages = mkIf cfg.enable [ pkgs.rke2 pkgs.kubernetes ];
    environment.etc."rancher/rke2/config.yaml" = mkIf (cfg.configFile != null) {
      source = cfg.configFile;
      user = "root";
    };
    systemd.services."rke2-${cfg.role}" = mkIf cfg.enable {
      enable = true;
      description = "Rancher Kubernetes Engine v2 (server)";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      conflicts = [ "rke2-agent.service" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ systemd gawk rke2 kmod util-linux iptables ];
      preStart = ''
                				! systemctl is-enabled --quiet nm-cloud-setup.service
        								modprobe br_netfilter
        								modprobe overlay
                				'';
      postStart = mkIf (cfg.role == "server") ''
        							mkdir -p /var/lib/rancher/rke2/server/manifests/
        							cp ${canalConfig} /var/lib/rancher/rke2/server/manifests/rke2-canal-config.yaml
        							cp ${nginxConfig} /var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml
        				'';
      script = ''rke2 ${cfg.role} ${builtins.concatStringsSep " " cfg.params}'';
      postStop = ''
        								set -x
                				systemd-cgls /system.slice/rke2-${cfg.role}.service | grep -Eo '[0-9]+ (containerd|kubelet)' | awk '{print $1}' | xargs -r kill
                				'';
      serviceConfig = {
        Type = "simple";
        KillMode = "process";
        Delegate = "yes";
        LimitNOFILE = 1048576;
        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        TasksMax = "infinity";
        TimeoutStartSec = 0;
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
