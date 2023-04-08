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
in {

  options = {
    nvidia.prime.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    # system packages for this machine
    environment.systemPackages = with pkgs; [
      nvtop
      (mkIf cfg.prime.enable nvidia-offload)
    ];

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.nvidiaPersistenced = true;

    hardware.nvidia.prime.offload.enable = mkIf cfg.prime.enable true;
    hardware.nvidia.powerManagement.finegrained = mkIf cfg.prime.enable true;

    services.xserver.videoDrivers = [ "nvidia" ];

    virtualisation.docker.enableNvidia =
      mkIf config.virtualisation.docker.enable true;
  };
}
