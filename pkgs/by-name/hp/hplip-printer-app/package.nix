{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  avahi,
  bind,
  cups,
  curl,
  gnupg,
  hplip,
  libcupsfilters,
  libppd,
  pappl-retrofit,
  pkg-config,
  pappl,
  perl,
  python3,
  systemd,
  withPlugin ? false,
}:

let
  hplipPkg = hplip.override { inherit withPlugin; };
in
stdenv.mkDerivation {
  pname = "hplip-printer-app";
  version = "3.22.10-24";

  src = fetchFromGitHub {
    owner = "OpenPrinting";
    repo = "hplip-printer-app";
    rev = "0f76e126228dc416ca10e4b3c1433d2f045c56cc";
    hash = "sha256-HIJMl0zW25uyHhIVtLvE0L7NzK3Nk2dbwGVJbafj3ak=";
  };

  nativeBuildInputs = [
    perl
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    avahi
    cups
    curl
    hplipPkg
    pappl
    pappl-retrofit
    libppd
    libcupsfilters
    systemd
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
    "sysconfdir=/etc"
    "localstatedir=/var"
    "cupsserverbin="
    "unitdir=${placeholder "out"}/lib/systemd/system"
    "HPLIP_CONF_DIR=${hplipPkg}/etc/hp"
    "HPLIP_PLUGIN_STATE_DIR=${hplipPkg}/var/lib/hp"
  ];

  installFlags = [
    "statedir=${placeholder "out"}/var/lib/hplip-printer-app"
    "spooldir=${placeholder "out"}/var/spool/hplip-printer-app"
  ];

  postInstall = ''
    # filters
    mkdir -p $out/lib/hplip-printer-app/filter
    ln -s ${hplipPkg}/lib/cups/filter/* $out/lib/hplip-printer-app/filter/

    # ppd files
    mkdir -p $out/lib/hplip-printer-app/ppd
    ln -s ${hplipPkg}/share/cups/model $out/lib/hplip-printer-app/ppd

    wrapProgram $out/bin/hplip-printer-app \
      --prefix PATH : ${
        lib.makeBinPath [
          hplipPkg
          perl
          avahi
          gnupg
          python3
          bind.dnsutils
        ]
      } \
      --set BACKEND_DIR "$out/lib/hplip-printer-app/backend" \
      --set FILTER_DIR "$out/lib/hplip-printer-app/filter" \
      --set PPD_PATHS "$out/lib/hplip-printer-app/ppd"
  '';

  meta = with lib; {
    description = "HPLIP Printer Application";
    homepage = "https://github.com/OpenPrinting/hplip-printer-app";
    license = if withPlugin then licenses.unfree else licenses.asl20;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
