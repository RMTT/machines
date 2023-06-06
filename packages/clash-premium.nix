{ stdenv, fetchurl, ... }:
let
  version = "2023.05.29";
  src = fetchurl {
    url =
      "https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-${version}.gz";
    sha256 = "sha256-pY0s0xuzoxdzWxHoOgztqf/MezIhvVBGBVYtJovHENU=";
  };
in stdenv.mkDerivation {
  pname = "clash-premium";
  version = version;
  src = src;

  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
        mkdir -p $out/bin
        gzip -c -d $src > $out/bin/clash
    		chmod +x $out/bin/clash
  '';
}
