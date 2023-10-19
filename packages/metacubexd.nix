{ stdenv, fetchurl, unzip, ... }:
let
  version = "1.124.0";
  src = fetchurl {
    name = "metacubexd";
    url =
      "https://github.com/MetaCubeX/metacubexd/releases/download/v${version}/compressed-dist.tgz";
    sha256 = "sha256-6IcIEYqzdtEVtxfqaa/wCtrHaEQRdg6id4+wzHA2vJk=";
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
