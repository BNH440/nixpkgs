{
  lib,
  stdenv,
  fetchFromGitHub,
  cups,
  libcupsfilters,
  libppd,
  pappl-retrofit,
  pkg-config,
  pappl,
  perl,
  systemd,
}:

stdenv.mkDerivation {
  pname = "ps-printer-app";
  version = "20240504-20";

  src = fetchFromGitHub {
    owner = "OpenPrinting";
    repo = "ps-printer-app";
    rev = "e7bd38229adf6027639fd361778f56c386cbc968";
    hash = "sha256-GwN7Vq1R0oIQuNF6DSs25vnaJ5AcmYum74yvY7zGRCk=";
  };

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [
    cups
    pappl
    pappl-retrofit
    libppd
    libcupsfilters
    systemd
  ];

  installFlags = [
    "prefix=${placeholder "out"}"
    "localstatedir=state"
    "unitdir=${placeholder "out"}/lib/systemd/system"
  ];

  meta = with lib; {
    description = "PostScript Printer Application";
    homepage = "https://github.com/OpenPrinting/ps-printer-app";
    license = licenses.asl20;
    maintainers = with lib.maintainers; [ bnh440 ];
    platforms = platforms.unix;
  };
}
