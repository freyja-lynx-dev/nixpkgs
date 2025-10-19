{
  lib,
  makeWrapper,
  autoPatchelfHook,
  stdenv,
  fetchurl,
  ncurses,
  dash,
  sqlite,
  gmp,
  fuse,
  re2,
  gnum4,
  iproute2,
  libgcc,
  openssl,
  dpkg,
#pie ? stdenv.hostPlatform.isDarwin
}:

let
  re2' = re2.overrideAttrs (oldAttrs: {
    version = "2022-02-01";
    src = fetchurl {
      url = "https://github.com/google/re2/archive/refs/tags/2022-02-01.tar.gz";
      hash = "sha256-nB5qz9D+1x9AsCWnodq68+4uu3TWTO0fnuGwsB0i/Sc=";
    };
  });
in
# vmTools.runInLinuxVM (
stdenv.mkDerivation (finalAttrs: {
  pname = "wake";
  version = "45.1.0";

  src = fetchurl {
    url = "https://github.com/sifiveinc/wake/releases/download/v${finalAttrs.version}/debian-bullseye-wake_${finalAttrs.version}-1_amd64.deb";
    hash = "sha256-YXBI/n+ZMmXjYa9ZkPeXaXTqKDPiuwZxv7SdoyULAVE=";
  };

  unpackCmd = ''
    dpkg -x $curSrc source
  '';

  # preUnpack = ''
  #   modprobe fuse || true
  # '';

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    dpkg
  ];

  buildInputs = [
    ncurses
    dash
    sqlite
    gmp
    fuse
    re2'
    gnum4
    iproute2
    libgcc
    openssl
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/wake

    # Copy prebuilt binaries if they exist
    cp -r bin/* $out/bin/ || true
    cp -r lib/wake/* $out/lib/wake/ || true

    # Wrap to set up environment
    for prog in $out/bin/*; do
      wrapProgram $prog \
        --prefix PATH : ${lib.makeBinPath [ ]} \
        --set WAKE_LIB $out/lib/wake
    done

    runHook postInstall
  '';

  # buildPhase = ''
  #   make
  # '';

  # postPatch = ''
  #   # Replace WAKE_ENV to include all needed tools
  #   substituteInPlace Makefile \
  #     --replace-fail \
  #       'WAKE_ENV := WAKE_PATH=$' \
  #       'WAKE_ENV := WAKE_PATH=${
  #         lib.makeBinPath [
  #           stdenv.cc
  #           coreutils
  #           gnum4
  #           dash
  #           which
  #           gzip
  #         ]
  #       }:$'
  # '';

  # installPhase = ''
  #   # echo "=== Checking for m4 ==="
  #   # ls -la ${gnum4}/bin/ || echo "gnum4 bin not found"

  #   # echo "=== Checking for dash ==="
  #   # ls -la ${dash}/bin/ || echo "dash bin not found"

  #   # echo "=== Current PATH ==="
  #   # echo $PATH

  #   # echo "=== Trying to run m4 directly ==="
  #   # ${gnum4}/bin/m4 --version || echo "m4 failed"

  #   make install
  # '';

  meta = {
    homepage = "https://github.com/sifiveinc/wake/";
    description = "Wake is a build orchestration tool and language.";
    license = lib.licenses.asl20;
    mainProgram = "wake";
    platforms = lib.platforms.linux;
  };
})
#)
