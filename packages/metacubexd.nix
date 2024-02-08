{ stdenv, fetchurl, ... }:
let
  version = "1.134.0";
  src = fetchurl {
    name = "metacubexd";
    url =
      "https://github.com/MetaCubeX/metacubexd/releases/download/v${version}/compressed-dist.tgz";
    sha256 = "sha256-Xx2UReUAxHg4CrKqGs9vGmWRsosJE1OqnYSmp2wOC9M=";
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
