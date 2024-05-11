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

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    which
    cmake
  ];
  buildInputs = [
    nlohmann_json
    unixtools.xxd
    openssl
  ];

  GIT_VERSION = version;
  GIT_REVISION = "bc23191";

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
    "-Wno-error"
  ];
  postFixup = ''
    wrapProgram $out/bin/${pname} --set PATH ${lib.makeBinPath [
      v4l-utils
    ]}
  '';
}

