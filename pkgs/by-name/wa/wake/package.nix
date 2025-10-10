{
  lib,
  pkg-config,
  makeWrapper,
  stdenv,
  fetchurl,
  ncurses,
  dash,
  sqlite,
  gmp,
  fuse,
  re2,
  gnum4,
  #pie ? stdenv.hostPlatform.isDarwin
}:

let
  re2' = re2.overrideAttrs (oldAttrs: {
    version = "2022-02-01";
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wake";
  version = "45.1.0";

  src = fetchurl {
    url = "https://github.com/sifiveinc/wake/releases/download/v${finalAttrs.version}/wake_${finalAttrs.version}.tar.xz";
    hash = "sha256-xleOx5tbEKZKj0VvTiuGtgnYK0xvejWBWlWOK7FctNw=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
   ncurses
   dash
   sqlite
   gmp
   fuse
   re2'
   gnum4
  ];

  buildPhase = ''
    make
  '';

  meta = {
    homepage = "https://github.com/sifiveinc/wake/";
    description = "Wake is a build orchestration tool and language.";
    license = lib.licenses.asl20;
    mainProgram = "wake";
    platforms = lib.platforms.unix;
  };
})
