{ pkgs, ... }: {
  # add development tools
  environment.systemPackages = with pkgs; [
    gcc
    llvmPackages_15.libclang
    gdb
    poetry
    jdk
    direnv
    nix-direnv
    cmake
    gradle
    gnumake
    bear
  ];
}
