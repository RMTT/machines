{ config, pkgs, lib, modules, ... }: {
  imports = with modules; [ base networking ];

  system.stateVersion = "24.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.k3s = {
    enable = true;
    role = "server";
    extraKubeProxyConfig = {
      mode = "nftables";
      clientConnection = { kubeconfig = "/etc/rancher/k3s/k3s.yaml"; };
    };
  };
}

