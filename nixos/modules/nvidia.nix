{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.nvidia;
  nvidia-package = config.boot.kernelPackages.nvidiaPackages.stable;
  nvidia-compute = pkgs.stdenv.mkDerivation {
    pname = "nvidia-compute";
    version = "0.1";
    src = null;
    dontBuild = true;
    dontUnpack = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/lib
      cp ${nvidia-package}/lib/libcuda* $out/lib
      cp ${nvidia-package}/lib/libnvcu* $out/lib
    '';
  };
  compute = (cfg.usage == "compute");
  full = (cfg.usage == "full");
in
{

  options = {
    nvidia.usage = mkOption {
      type = types.str;
      default = "full";
      description = ''
        full: use nvidia for render and compute
        compute: use nvidia for only compute'';
    };

  };
  config = mkMerge [
    {
      virtualisation.docker.enableNvidia = config.virtualisation.docker.enable;

      # system packages for this machine
      environment.systemPackages = with pkgs; [
        nvtop
        (mkIf compute nvidia-package.bin)
      ];

      # Load nvidia driver for Xorg and Wayland
      services.xserver.videoDrivers = mkIf full [ "nvidia" ];

      hardware.nvidia = {
        # Modesetting is required for display.
        modesetting.enable = true;

        powerManagement = { enable = true; };
        nvidiaSettings = true;
        package = nvidia-package;
      };

    }
    (mkIf compute {
      hardware.opengl = {
        extraPackages = [ nvidia-compute ];
        extraPackages32 = [ nvidia-compute ];
      };
      boot = {
        extraModulePackages = [ nvidia-package.bin ];
        blacklistedKernelModules = [ "nvidia_modeset" "nouveau" ];
        kernelParams = [ "module_blacklist=nvidia_modeset,nouveau" ];
        kernelModules = [ "nvidia_uvm" "nvidia" "nvidia_drm" ];
      };
      services.udev.extraRules = ''
        # Create /dev/nvidia-uvm when the nvidia-uvm module is loaded.
        KERNEL=="nvidia", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidiactl c 195 255'"
        KERNEL=="nvidia", RUN+="${pkgs.runtimeShell} -c 'for i in $$(cat /proc/driver/nvidia/gpus/*/information | grep Minor | cut -d \  -f 4); do mknod -m 666 /dev/nvidia$''${i} c 195 $''${i}; done'"
        KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
        KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm-tools c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 1'"
      '';
      systemd.services = {
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
    })
  ];
}
