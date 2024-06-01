{ stdenv, fetchurl, ... }:
let
  version = "1.138.1";
  src = fetchurl {
    name = "metacubexd";
    url =
      "https://github.com/MetaCubeX/metacubexd/releases/download/v${version}/compressed-dist.tgz";
    sha256 = "sha256-l2mcb2optvgtfzma/Ix63Y8BxXC6CsGoyIIMoOvD074=";
  };
in stdenv.mkDerivation {
  pname = "metacubexd";
  version = version;
  src = src;

  unpackPhase = ''
    tar zxvf ${src}
  '';
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/public
    cp -r ./* $out/public
  '';
}
