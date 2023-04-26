{ pkgs, ... }: {
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
    cmake-language-server
    tree-sitter
    nodejs
    ccls
    clang-tools
    pkg-config
  ];
}
