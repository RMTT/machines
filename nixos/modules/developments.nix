{ pkgs, ... }: {
  config = {
    # add development tools
    environment.systemPackages = with pkgs; [
      gcc
      gdb
      poetry
      jdk
      cmake
      gradle
      gnumake
      bear
      google-cloud-sdk
      nodejs
      clang-tools
      pkg-config
      pgcli
    ];

  };
}
