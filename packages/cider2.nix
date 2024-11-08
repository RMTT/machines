{ appimageTools
, fetchurl
}:

let
  pname = "cider";
  version = "2.5.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://cloud.rmtt.tech/s/qqzRgg5FN26BdEs/download";
    sha256 = "sha256-HwfByY8av1AvI+t7wnaNbhDLXBxgzRKYiLG1hPUto9o=";
  };
  appimageContents = appimageTools.extractType1 { inherit name src; };
in
appimageTools.wrapType1 {
  inherit name src;

  extraInstallCommands = ''
        mv $out/bin/${name} $out/bin/${pname}
        install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace-fail 'Exec=AppRun' 'Exec=${pname} ''${NIXOS_OZONE_WL:+''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}'
        cp -r ${appimageContents}/usr/share/icons $out/share
    		'';

  meta = {
    description = "A new look into listening and enjoying Apple Music in style and performance.";
    homepage = "https://cider.sh/";
    platforms = [ "x86_64-linux" ];
  };
}

