{ stdenv
, lib
, fetchurl
, pipewire
, makeWrapper
, xar
, cpio
  # Dynamic libraries
, alsa-lib
, atk
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, dbus
, expat
, libdrm
, libGL
, fontconfig
, freetype
, gtk3
, gdk-pixbuf
, glib
, mesa
, nspr
, nss
, pango
, wayland
, xorg
, libxkbcommon
, udev
, zlib
, libkrb5
  # Runtime
, coreutils
, pciutils
, procps
, util-linux
, pulseaudioSupport ? true
, libpulseaudio
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  # Zoom versions are released at different times for each platform
  # and often with different versions.  We write them on three lines
  # like this (rather than using {}) so that the updater script can
  # find where to edit them.
  versions.x86_64-linux = "6.1.6.1013";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://cdn.zoom.us/prod/${versions.x86_64-linux}/zoom_x86_64.pkg.tar.xz";
      hash = "sha256-mvCJft0suOxnwTkWWuH9OYKHwTMWx61ct10P5Q/EVBM=";
    };
  };

  libs = lib.makeLibraryPath ([
    # $ LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:$PWD ldd zoom | grep 'not found'
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    libdrm
    libGL
    pipewire
    fontconfig
    freetype
    gtk3
    gdk-pixbuf
    glib
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc
    wayland
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    libxkbcommon
    xorg.libXrandr
    xorg.libXrender
    xorg.libxshmfence
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.libXfixes
    xorg.libXtst
    udev
    zlib
    libkrb5
  ] ++ lib.optional (pulseaudioSupport) libpulseaudio);

in
stdenv.mkDerivation rec {
  pname = "zoom";
  version = versions.${system} or throwSystem;

  src = srcs.${system} or throwSystem;

  dontUnpack = stdenv.isLinux;
  unpackPhase = lib.optionalString stdenv.isDarwin ''
    xar -xf $src
    zcat < zoomus.pkg/Payload | cpio -i
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.isDarwin [
    xar
    cpio
  ];

  installPhase = ''
    runHook preInstall
    ${rec {
      aarch64-darwin = ''
        mkdir -p $out/Applications
        cp -R zoom.us.app $out/Applications/
      '';
      # darwin steps same on both architectures
      x86_64-darwin = aarch64-darwin;
      x86_64-linux = ''
        mkdir $out
        tar -C $out -xf $src
        mv $out/usr/* $out/
      '';
    }.${system} or throwSystem}
    runHook postInstall
  '';

  postFixup =  lib.optionalString stdenv.isDarwin ''
    makeWrapper $out/Applications/zoom.us.app/Contents/MacOS/zoom.us $out/bin/zoom
  '' + lib.optionalString stdenv.isLinux ''
    # Desktop File
    substituteInPlace $out/share/applications/Zoom.desktop \
        --replace "Exec=/usr/bin/zoom" "Exec=$out/bin/zoom"

    for i in aomhost zopen zoom ZoomLauncher ZoomWebviewHost; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/zoom/$i
    done

    # ZoomLauncher sets LD_LIBRARY_PATH before execing zoom
    # IPC breaks if the executable name does not end in 'zoom'
    mv $out/opt/zoom/zoom $out/opt/zoom/.zoom
    makeWrapper $out/opt/zoom/.zoom $out/opt/zoom/zoom \
      --prefix LD_LIBRARY_PATH ":" ${libs}

    mv $out/opt/zoom/ZoomWebviewHost $out/opt/zoom/.ZoomWebviewHost
    makeWrapper $out/opt/zoom/.ZoomWebviewHost $out/opt/zoom/ZoomWebviewHost \
      --prefix LD_LIBRARY_PATH ":" ${libs}

    rm $out/bin/zoom
    # Zoom expects "zopen" executable (needed for web login) to be present in CWD. Or does it expect
    # everybody runs Zoom only after cd to Zoom package directory? Anyway, :facepalm:
    # Clear Qt paths to prevent tripping over "foreign" Qt resources.
    # Clear Qt screen scaling settings to prevent over-scaling.
    makeWrapper $out/opt/zoom/ZoomLauncher $out/bin/zoom \
      --chdir "$out/opt/zoom" \
      --unset QML2_IMPORT_PATH \
      --unset QT_PLUGIN_PATH \
      --prefix PATH : ${lib.makeBinPath [ coreutils glib.dev pciutils procps util-linux ]} \
      --prefix LD_LIBRARY_PATH ":" ${libs}

    # Backwards compatibility: we used to call it zoom-us
    ln -s $out/bin/{zoom,zoom-us}
  '';

  # already done
  dontPatchELF = true;

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    homepage = "https://zoom.us/";
    description = "zoom.us video conferencing application";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = builtins.attrNames srcs;
    maintainers = with maintainers; [ danbst tadfisher ];
    mainProgram = "zoom";
  };
}