{ python3Packages, fetchFromGitHub, meson, ncurses, readline, ninja, automake
, autoconf, libtool, gnumake, pkg-config, gettext, perl, gperf, flex, bison
, openssl, git, cacert, iproute2 }:
python3Packages.buildPythonApplication {
  name = "aronet";
  version = "v0.1-beta";
  pyproject = true;
  buildInputs = [ iproute2 openssl ncurses readline ];
  nativeBuildInputs = [
    ninja
    automake
    autoconf
    pkg-config
    git
    libtool
    gperf
    bison
    flex
    gettext
    gnumake
    perl
  ];

  dependencies = with python3Packages; [ cryptography pyroute2 jsonschema ];
  build-system = with python3Packages; [ build meson-python ];

  postPatch = ''
    # wrap-git needs .git
    for prj in subprojects/*.wrap; do
      pushd subprojects/$(basename "$prj" .wrap)
      git init
      popd
    done

    patchShebangs subprojects/bird/build.sh
    patchShebangs subprojects/strongswan/build.sh
  '';

  src = fetchFromGitHub {
    owner = "RMTT";
    repo = "aronet";
    rev = "65ccb3e00303369b51b6583db350b5054d7e0b56";
    hash = "sha256-mefb7YXafK7uGb+T48aHe4I/8/g7fLnLXpfX/OlJFBo=";
    nativeBuildInputs = [ git meson cacert ];
    postFetch = ''
      cd "$out"
      for prj in subprojects/*.wrap; do
        meson subprojects download "$(basename "$prj" .wrap)"
        rm -rf subprojects/$(basename "$prj" .wrap)/.git
      done
    '';
  };
}
