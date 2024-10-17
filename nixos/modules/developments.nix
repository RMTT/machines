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
      google-cloud-sdk
      nodejs
      clang-tools
      pkg-config
      pgcli
			yq-go
			gh
			distrobox
			go
			tldr
			rustup
    ];

  };
}
