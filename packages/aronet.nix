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
    rev = "b371d237297c262d31233da37b7b09136201394b";
    hash = "sha256-1z+e2sV5j+b1550h4hOMkRc9nZVcK9g0YxZy8w/OMyI=";
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
