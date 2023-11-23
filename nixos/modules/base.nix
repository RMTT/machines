# Base configuratioj
{ pkgs, lib, config, ... }:
let cfg = config.base;
in with lib; {
  imports = [ ./libvirtd.nix ];

  options.base = {
    onedrive.enable = mkOption {
      type = types.bool;
      default = false;
    };

    gl.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };
  config = {
    # enable unfree pkgs
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.joypixels.acceptLicense = true;
    nixpkgs.config.permittedInsecurePackages = [ "zotero-6.0.27" ];

    # binary cache
    nix.settings.substituters =
      [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
    nix.settings.trusted-users = [ "root" "mt" ];
    nix.optimise.automatic = true;
    nix.gc.automatic = true;

    # enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.grub.configurationLimit = 10;

    boot.kernelModules = [ "wireguard" ];

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
    time.hardwareClockInLocalTime = true;

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
      smartmontools
      eza
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
      bridge-utils
      home-manager
      wireguard-tools
      efibootmgr
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
      package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };

    # enable ssh
    services.openssh = {
      enable = true;
      settings = { PasswordAuthentication = false; };
    };

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
      shellInit = ''
        bindkey -e
      '';
    };

    # main user
    security.sudo = { wheelNeedsPassword = false; };
    users.mutableUsers = true;
    users.users.mt = {
      isNormalUser = true;
      home = "/home/mt";
      description = "mt";
      extraGroups = [
        "wheel"
        "networkmanager"
        (mkIf config.virtualisation.docker.enable "docker")
        "video"
        "kvm"
      ];
      initialHashedPassword =
        "$y$j9T$RHlCoWbFSwNhdz9.5Y7Hy.$6CrlIcp6sl9vbBJL.ZcvJaq1KCZJ3RLV228gMezSBGA";
      openssh.authorizedKeys.keyFiles = [ ../../secrets/ssh_key.pub ];
    };
    users.users.root = {
      openssh.authorizedKeys.keyFiles = [ ../../secrets/ssh_key.pub ];
      initialHashedPassword =
        "$y$j9T$I.Ih8kx/HR9/iI.Mhbsz./$apkdSpL9tpDTBJRjCgKCUikijFkA2cuUhJYecOBT0cC";
    };

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
      setLdLibraryPath = true;
      extraPackages = with pkgs; [
        libva
        mesa.drivers
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # enable onedrive
    services.onedrive.enable = cfg.onedrive.enable;
  };
}
