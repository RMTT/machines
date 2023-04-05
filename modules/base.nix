# Base configuration
{ pkgs, lib, ... }: {
  # timezone
  time.timeZone = "Asia/Shanghai";

  # locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales =
    [ "en_US.UTF-8" "zh_CN.UTF-8" "zh_TW.UTF-8" "ja_JP.UTF-8" ];

  # console
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # system packages
  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    terminus_font
  ];

  # enable ssh
  services.openssh.enable = true;

  # cpu governor
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # hardware related
  hardware.video.hidpi.enable = true;
}
