{ config, pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {

  # system packages for this machine
  environment.systemPackages =
    [ config.boot.kernelPackages.nvidia_x11 nvidia-offload ];

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;

  hardware.nvidia.prime = { offload.enable = true; };

  services.xserver.videoDrivers = [ "nvidia" ];
}
