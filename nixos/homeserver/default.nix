{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/secrets.nix
    ../modules/base.nix
    ../modules/fs.nix
    ../modules/networking.nix
    ../modules/services.nix
    ../modules/docker.nix
  ];

  config = with lib; {
    # set filesystems mount
    fs.btrfs.label = "@data";
    fs.btrfs.volumes = {
      "/data" = [ "subvol=/" "rw" "relatime" "ssd" "space_cache=v2" ];
    };
    fs.normal.volumes = {
      "/" = {
        fsType = "ext4";
        label = "@";
        options =
          [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
      };
    };
    fs.swap.label = "@swap";
    fs.boot.label = "@boot";

    hardware.cpu.intel.updateMicrocode = true;

    boot.kernel.sysctl = {
      "vm.overcommit_memory" = 1;
      "net.ipv6.route.max_size" = 409600;
    };

    virtualisation.docker.portainer.enable = true;

    # gpu setting
    services.xserver.videoDrivers = [ "i915" ];

    networking.useNetworkd = true;

    # networking related
    networking.firewall.allowedTCPPorts = [ 1443 ];

    services.resolved.extraConfig = ''
                  DNSStubListener = false
            			LLMNR = false
            			MulticastDNS = false
      						DNSSEC = false
    '';

    base.onedrive.enable = true;

    # set msmtp, for sending notification
    sops.secrets.zoho-pass = { mode = "644"; };
    programs.msmtp = {
      enable = true;
      accounts = {
        default = {
          auth = true;
          tls = true;
          tls_starttls = false;
          from = "notify@rmtt.tech";
          host = "smtppro.zoho.com";
          port = 465;
          user = "d.rong@outlook.com";
          passwordeval =
            "${pkgs.coreutils}/bin/cat ${config.sops.secrets.zoho-pass.path}";
        };
      };
    };

    # config smartd, monitor disk status
    services.smartd = {
      enable = true;
      notifications.test = true;
      notifications.mail = {
        enable = true;
        recipient = "d.rong@outlook.com";
        sender = "notify@rmtt.tech";
      };
    };
  };

}
