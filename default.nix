{ clangStdenv
, fetchFromGitHub
, pkg-config
, which
, nlohmann_json
, unixtools
, cmake
, openssl
, lib
, v4l-utils
, makeWrapper
}:

clangStdenv.mkDerivation rec {
  pname = "camera-streamer";
  version = "0.2.8";

  src = ./.;

  buildInputs = [
    pkg-config
    which
    nlohmann_json
    unixtools.xxd
    cmake
    openssl
  ];
  nativeBuildInputs = [
    makeWrapper
  ];

  GIT_VERSION = version;
  GIT_REVISION = "bc23191";
  DESTDIR = "$out";

  patchPhase = ''
    # sed -i 's/\[N_FDS\]/\[\(unsigned int\)N_FDS\]/g' device/links.c
    # sed -i '/GIT_VERSION/s/echo/printf/g' Makefile
    # sed -i '/GIT_VERSION/s/\\""/\\"\\n"/g' Makefile
    # sed -i 's/system("v4l2/(void)system("v4l2/g' device/camera/camera_input.c
  '';
  dontUseCmakeConfigure = true;
  configureFlags = [
    "--disable-werror"
  ];
  installPhase = ''
    mkdir -p $out/bin
    export DESTDIR=$out
    install camera-streamer $out/bin/${pname}
  '';
  NIX_CFLAGS_COMPILE = [
    # "-Wno-unused-but-set-variable"
    "-Wno-error"
  ];
  postFixup = ''
    wrapProgram $out/bin/${pname} --set PATH ${lib.makeBinPath [
      v4l-utils
    ]}
  '';
}

