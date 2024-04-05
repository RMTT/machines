{ stdenv }: stdenv.mkDerivation rec{
  pname = "udp2raw-bin";
  version = "20230206.0";

  src = builtins.fetchurl {
    url = "https://github.com/wangyu-/udp2raw/releases/download/20230206.0/udp2raw_binaries.tar.gz";
    sha256 = "sha256:1s67s9dzksmknd5yypd3yq1bx9iy5iic8sscjns50zm939wgag2h";
  };

  unpackPhase = ''
    		tar zxvf $src
    	'';

  installPhase = ''
    		mkdir -p $out/bin
				cp udp2raw_amd64 $out/bin/udp2raw
  '';

  dontConfigure = true;
  dontBuild = true;
  doInstallCheck = true;
}
