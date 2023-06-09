# Base configuratioj
{ pkgs, pkgs-unstable, lib, config, inputs, ... }:
let cfg = config.base;
in with lib; {
  options.base = {
    libvirt.enable = mkOption {
      type = types.bool;
      default = false;
    };

    onedrive.enable = mkOption {
      type = types.bool;
      default = false;
    };

    libvirt.qemuHook = mkOption {
      type = types.path;
      default = null;
      description = ''
        libvirt qemu hook, reference: https://www.libvirt.org/hooks.html
      '';
    };
    gl.enable = mkOption {
      type = types.bool;
      default = true;
    };

    mt.password = mkOption {
      type = types.bool;
      default = true;
      description = ''
        set default password from sops
      '';
    };
  };
  config = {
    # enable unfree pkgs
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.joypixels.acceptLicense = true;

    # binary cache
    nix.settings.substituters =
      [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
    nix.settings.trusted-users = [ "root" "mt" ];
    nix.optimise.automatic = true;
    nix.gc.automatic = true;

    # enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.registry = {
      self.flake = inputs.self;
      nixpkgs.flake = inputs.nixpkgs;

      nixpkgs-unstable.flake = inputs.nixpkgs-unstable;

      home-manager.flake = inputs.home-manager;

      flake-utils.flake = inputs.flake-utils;
    };

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
    time.timeZone = ":/etc/localtime";
		time.hardwareClockInLocalTime = true;
		environment.variables = {
			TZ = "Asia/Shanghai";
		};

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
      gh
      wget
      curl
      pciutils
      usbutils
      inetutils
      neofetch
      zsh
      python3Full
      tmux
      gitui
      ripgrep
      iptables
      nftables
      tcpdump
      man-pages
      gnupg
      bitwarden-cli
      sops
      bitwarden-cli
      yubikey-manager
      yubikey-touch-detector
      yubikey-personalization
      yubico-pam
      jq
      unzip
      zip
      libcgroup
      bridge-utils
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
      viAlias = true;
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

    # enable zsh
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
      shellInit = "	bindkey -e\n";
    };

    # main user
    security.sudo = { wheelNeedsPassword = false; };
    sops.secrets.mt-pass = mkIf cfg.mt.password { neededForUsers = true; };
    users.users.mt = {
      isNormalUser = true;
      home = "/home/mt";
      description = "mt";
      extraGroups =
        [ "wheel" "networkmanager" "docker" "video" "libvirtd" "kvm" ];
      shell = pkgs.zsh;
      passwordFile = mkIf cfg.mt.password config.sops.secrets.mt-pass.path;
      openssh.authorizedKeys.keyFiles = [ ../../secrets/ssh_key.pub ];
    };
    environment.pathsToLink = [ "/share/zsh" ];

    # configure tmux
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      extraConfig = ''
        set -s default-terminal 'screen-256color'
      '';
    };

    # yubikey related
    services.udev.packages = with pkgs; [ yubikey-personalization ];
    services.pcscd.enable = true;

    # enable yubikey otp
    security.pam.yubico = {
      enable = true;
      mode = "challenge-response";
    };

    # opengl and hardware acc
    hardware.opengl = mkIf cfg.gl.enable {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        libva
        mesa.drivers
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # enable libvirt
    virtualisation.libvirtd = { enable = cfg.libvirt.enable; };
    virtualisation.spiceUSBRedirection.enable = cfg.libvirt.enable;
    systemd.services.libvirtd = mkIf cfg.libvirt.enable {
      path = [ pkgs.bash ];
      preStart = mkIf (cfg.libvirt.qemuHook != null) ''
        mkdir -p /var/lib/libvirt/hooks
        chmod 755 /var/lib/libvirt/hooks

        # Copy hook files
        ln -sf ${cfg.libvirt.qemuHook} /var/lib/libvirt/hooks/qemu
      '';
    };

    # enable onedrive
    services.onedrive.enable = cfg.onedrive.enable;

    # enable home-manager for users
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
}

