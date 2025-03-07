{ python3Packages, fetchFromGitHub, meson, ncurses, readline, ninja, automake
, autoconf, libtool, gnumake, pkg-config, gettext, perl, gperf, flex, bison
, openssl, git, cacert, keepBuildTree }:
python3Packages.buildPythonApplication {
  name = "aronet";
  version = "v0.1-beta";
  pyproject = true;
  buildInputs = [ ncurses readline openssl ];
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
    keepBuildTree
    perl
  ];

  dependencies = with python3Packages; [
    cryptography
    pyroute2
    jsonschema

  ];
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
    rev = "633ed9dea78ed755776b1dd40cba120c61d49cf8";
    hash = "sha256-2tlry0JXyaVRC9RyT3o+a1an7kSIbuiywZBBpzxRKYk=";
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
