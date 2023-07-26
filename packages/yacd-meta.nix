{ stdenv, fetchurl, unzip, ... }:
let
  version = "0.3.7";
  src = fetchurl {
    name = "yacd-meta.zip";
    url = "https://github.com/MetaCubeX/yacd/archive/gh-pages.zip";
    sha256 = "sha256-UzHTKdqqytLQtm+eB1VhfhZGP16YI9jSOwgCvaC/Q7M=";
  };
in stdenv.mkDerivation {
  pname = "yacd-meta";
  version = version;
  src = src;
  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip ${src}
  '';
  dontBuild = true;
  installPhase = ''
    mkdir $out
    cp -r Yacd-meta-gh-pages/* $out
  '';
}
