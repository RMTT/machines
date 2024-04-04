{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, makeWrapper
, getent
, iproute2
, iptables
, shadow
}:

let
  version = "1.58.2";
in
buildGoModule {
  pname = "derper";
  inherit version;

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${version}";
    hash = "sha256-FiFFfUtse0CKR4XJ82HEjpZNxCaa4FnwSJfEzJ5kZgk=";
  };
  vendorHash = "sha256-BK1zugKGtx2RpWHDvFZaFqz/YdoewsG8SscGt25uwtQ=";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ makeWrapper ];

  CGO_ENABLED = 0;

  subPackages = [ "cmd/derper" ];

  ldflags = [
    "-w"
    "-s"
    "-X tailscale.com/version.longStamp=${version}"
    "-X tailscale.com/version.shortStamp=${version}"
  ];

  doCheck = false;

  postInstall = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/derper --prefix PATH : ${lib.makeBinPath [ iproute2 iptables getent shadow ]}
  '';

  meta = with lib; {
    homepage = "https://tailscale.com";
    description = "tailscale derp server";
    license = licenses.bsd3;
    mainProgram = "tailscale";
  };
}
