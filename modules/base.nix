# Base configuration
{ pkgs, pkgs-unstable, lib, ... }: {
  # binary cache
  nix.settings.substituters =
    [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
  nix.settings.trusted-users = [ "root" "mt" ];

  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  # console
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # system packages
  environment.systemPackages = with pkgs; [
    git
    gh
    wget
    curl
    terminus_font
    linux-firmware
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
  ];

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
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # hardware related
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # enable unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # main user
  users.users.mt = {
    isNormalUser = true;
    home = "/home/mt";
    description = "mt";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
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
}
