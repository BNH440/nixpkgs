{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  autoreconfHook,
  pkg-config,
  cups,
  libcupsfilters,
  libppd,
  pappl,
}:

stdenv.mkDerivation rec {
  pname = "pappl-retrofit";
  version = "1.0b2";

  src = fetchFromGitHub {
    owner = "OpenPrinting";
    repo = "pappl-retrofit";
    rev = version;
    hash = "sha256-YBU1uFleyDsseHnEnbEd4XFL/4NF2WTMK3kNDZjyBaY=";
  };

  patches = [
    (fetchpatch {
      name = "include-cups-sidechannel-h.patch";
      url = "https://github.com/OpenPrinting/pappl-retrofit/commit/0317fae79cef0c2ed47850183bf64116004ad3c7.patch";
      sha256 = "sha256-kIpA9vuBY4j74hg3uovbYWMC/pZGZwqvVlHHzJW/8Vo=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    cups
    pappl
    libcupsfilters
    libppd
  ];

  postInstall = ''
    rm -rf $out/var
  '';

  meta =
    let
      homepage = "https://github.com/OpenPrinting/pappl-retrofit";
    in
    with lib;
    {
      description = "PPD/Classic CUPS driver retro-fit Printer Application Library";
      inherit homepage;
      changelog = "${homepage}/releases/tag/${version}";
      license = licenses.asl20;
      maintainers = [ ];
      platforms = platforms.unix;
    };
}
