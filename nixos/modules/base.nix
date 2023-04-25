# Base configuration
{ pkgs, pkgs-unstable, lib, config, ... }:
let cfg = config.base;
in with lib; {
  options.base = {
    libvirt.qemuHook = mkOption {
      type = types.path;
      default = null;
      description = ''
        libvirt qemu hook, reference: https://www.libvirt.org/hooks.html
      '';
    };
  };
  config = {
    # binary cache
    nix.settings.substituters =
      [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
    nix.settings.trusted-users = [ "root" "mt" ];

    # enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # common initrd options
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
      "btrfs"
    ];

    # timezone
    time.timeZone = "Asia/Shanghai";

    # locale
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
      "zh_TW.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];

    # swap caps and escape
    services.xserver.xkbOptions = "caps:swapescape";

    # console
    console = {
      font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
      packages = with pkgs; [ terminus_font ];
      useXkbConfig = true;
    };

    # system packages
    environment.systemPackages = with pkgs; [
      exa
      parted
      bind
      htop
      gitFull
      pgcli
      gh
      wget
      curl
      pciutils
      usbutils
      neofetch
      zsh
      python3Full
      tmux
      gitui
      ripgrep
      iptables
      nftables
      man-pages
      gnupg
      bitwarden-cli
      rclone
      nixos-option
      sops
      bitwarden-cli
      yubikey-manager
      yubikey-touch-detector
      yubikey-personalization
      yubico-pam
      jq
      unzip
      zip
    ];

    # set XDG viarables
    environment.sessionVariables = rec {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";

      PATH = [ "${XDG_BIN_HOME}" ];
    };

    # set default editor to nvim
    programs.neovim = {
      enable = true;
      package = pkgs-unstable.neovim-unwrapped;
      defaultEditor = true;
      vimAlias = true;
    };

    # enable ssh
    services.openssh.enable = true;

    # enable docker
    virtualisation.docker.enable = true;

    # cpu governor
    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

    # enable acpid
    services.acpid.enable = true;

    # hardware related
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;

    # enable unfree pkgs
    nixpkgs.config.allowUnfree = true;

    # enable zsh
    programs.zsh = {
      enable = true;
      enableCompletion = false;
      enableGlobalCompInit = false;
    };

    # main user
    users.users.mt = {
      isNormalUser = true;
      home = "/home/mt";
      description = "mt";
      extraGroups =
        [ "wheel" "networkmanager" "docker" "video" "libvirtd" "kvm" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = [ ../../secrets/ssh_key.pub ];
    };
    environment.pathsToLink = [ "/share/zsh" ];

    # configure tmux
    programs.tmux = {
      enable = true;
      clock24 = true;
      extraConfig = ''
        set -s default-terminal 'screen-256color'
        set -g mouse on
        setw -g mode-keys vi
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      '';
    };

    # yubikey related
    services.udev.packages = with pkgs; [ yubikey-personalization ];
    services.pcscd.enable = true;

    # enable yubikey otp
    security.pam.yubico = {
      enable = true;
      debug = true;
      mode = "challenge-response";
    };

    # opengl and hardware acc
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
    hardware.opengl.extraPackages = with pkgs; [
      libva
      mesa.drivers
      vaapiVdpau
      libvdpau-va-gl
    ];

    # enable libvirt
    virtualisation.libvirtd = { enable = true; };
    virtualisation.spiceUSBRedirection.enable = true;
    systemd.services.libvirtd.path = [ pkgs.bash ];
    systemd.services.libvirtd.preStart = mkIf (cfg.libvirt.qemuHook != null) ''
      mkdir -p /var/lib/libvirt/hooks
      chmod 755 /var/lib/libvirt/hooks

      # Copy hook files
      ln -sf ${cfg.libvirt.qemuHook} /var/lib/libvirt/hooks/qemu
    '';

    # enable onedrive
    services.onedrive.enable = true;
  };
}
