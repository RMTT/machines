{ config, pkgs, lib, ... }:
let cfg = config.virtualisation.libvirtd;
in with lib; {
  options = {
    virtualisation.libvirtd = {
      qemuHook = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          libvirt qemu hook, reference: https://www.libvirt.org/hooks.html
        '';
      };

      vfio.enable = mkOption {
        type = types.bool;
        default = false;
      };

      vfio.deviceIds = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    # enable libvirt
    virtualisation.spiceUSBRedirection.enable = true;
    systemd.services.libvirtd = {
      path = [ pkgs.bash ];
      preStart = mkIf (cfg.qemuHook != null) ''
        mkdir -p /var/lib/libvirt/hooks
        chmod 755 /var/lib/libvirt/hooks

        # Copy hook files
        ln -sf ${cfg.qemuHook} /var/lib/libvirt/hooks/qemu
      '';
    };

    boot = mkIf cfg.vfio.enable {
      initrd.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" ];
      kernelParams = mkIf ((length cfg.vfio.deviceIds) != 0)
        [ ("vfio-pci.ids=" + concatStringsSep "," cfg.vfio.deviceIds) ];
    };
  };
}
