{ appimageTools, fetchurl, writeScript }:

let
  pname = "Cider";
  version = "2.6.0";

  src = fetchurl {
    url = "https://cloud.rmtt.tech/s/c6XLCSq9gjR2TbG/download";
    sha256 = "sha256-q9ulXYha5PSZbYZ/oxOvGvK5XGn0TlAGMymju5fXwmU=";
  };
  appimageContents = appimageTools.extract { inherit pname src version; };
  ciderBin = writeScript "cider" ''
    exec Cider  ''${NIXOS_OZONE_WL:+''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}  "$@"
  '';
in appimageTools.wrapType2 {
  inherit pname src version;

  extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
        cp ${ciderBin} $out/bin/cider

        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace-fail 'Exec=${pname}' 'Exec=cider'
        cp -r ${appimageContents}/usr/share/icons $out/share
    		'';

  meta = {
    description =
      "A new look into listening and enjoying Apple Music in style and performance.";
    homepage = "https://cider.sh/";
    platforms = [ "x86_64-linux" ];
  };
}

