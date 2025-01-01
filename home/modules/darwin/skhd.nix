{ config, lib, ... }:
lib.mkIf (config.nixpkgs.system == "aarch64-darwin") {
  home.file.".config/skhd" = {
    source = ../../config/skhd;
    recursive = true;
  };
}
