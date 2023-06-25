{ stdenv, fetchurl, unzip, ... }:
let
  version = "0.3.6";
  src = fetchurl {
		name = "yacd-meta.zip";
    url =
      "https://codeload.github.com/MetaCubeX/Yacd-meta/zip/refs/heads/gh-pages";
    sha256 = "sha256-YIHisqbfTvkZOCFHpU3R1YHh/M5dBk+Owi7HC3k5rco=";
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
