{ python3Packages, fetchFromGitHub, meson, ncurses, readline, ninja, automake
, autoconf, libtool, gnumake, pkg-config, gettext, perl, gperf, flex, bison
, openssl, git, cacert, iproute2 }:
python3Packages.buildPythonApplication {
  name = "aronet";
  version = "v0.1-beta1";
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
    rev = "v0.1-beta1";
    hash = "sha256-2ouJ5P8ntwDBh1EGkcH6T3fTZj4zaBeXWPq5PtUp3p4=";
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
