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
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
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
    pkgs-unstable.v2raya
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

  # enable acpid
  services.acpid.enable = true;

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
    extraGroups = [ "wheel" "networkmanager" "docker" "video" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAELAVVWvq1uDn9SxZt+tL+CpbsPvUElnUNe29VnDHccurfc8wDkPBqwqo9oaaweTkPQ8orI38uPG68OCeaMEKm6FgDt68f0B+yp8YTQ8nS0pL5JAnxyHZfa+98N/TBF/Wlm/Ns1oJAv5ru3BNT6FQ4jXp9IuNxDF9S8ZtmpYxhrPd2vfQ== cardno:16 808 981"
    ];
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
