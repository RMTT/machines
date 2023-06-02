{ config, pkgs, lib, ... }:
with lib;
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';

  cfg = config.nvidia;
  nvidia-package = config.boot.kernelPackages.nvidiaPackages.stable;
  full = (cfg.usage == "full");
  onlyCompute = (cfg.usage == "compute");
in {

  options = {
    nvidia.prime.enable = mkOption {
      type = types.bool;
      default = false;
    };

    nvidia.usage = mkOption {
      type = types.str;
      default = "full";
      description = ''
        full: use nvidia for render and compute
        				compute: use nvidia for only compute'';
    };

  };

  config = {
    virtualisation.docker.enableNvidia = config.virtualisation.docker.enable;

    services.xserver.videoDrivers = mkIf full [ "nvidia" ];

    # system packages for this machine
    environment.systemPackages = with pkgs; [
      nvtop
      (mkIf onlyCompute nvidia-package.bin)
      (mkIf (full && cfg.prime.enable) nvidia-offload)
    ];

    hardware.nvidia.package = nvidia-package;

    # full part
    hardware.nvidia.prime.offload.enable = mkIf full cfg.prime.enable;
    hardware.nvidia.modesetting.enable = mkIf full true;
    hardware.nvidia.nvidiaPersistenced = mkIf full true;
    hardware.nvidia.powerManagement.enable = mkIf full true;

    # only compute part
    boot.extraModulePackages = mkIf onlyCompute [ nvidia-package ];
    boot.blacklistedKernelModules =
      mkIf onlyCompute [ "nouveau" "nvidia_modeset" "nvidia_uvm" ];

    systemd.services = mkIf onlyCompute {
      "nvidia-persistenced" = {
        description = "NVIDIA Persistence Daemon";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "forking";
          Restart = "always";
          PIDFile = "/var/run/nvidia-persistenced/nvidia-persistenced.pid";
          ExecStart =
            "${nvidia-package.persistenced}/bin/nvidia-persistenced --verbose";
          ExecStopPost =
            "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-persistenced";
        };
      };
    };
  };
}
