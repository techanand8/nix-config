{
  pkgs,
  vars,
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "xppen-mini7v2-official";
  version = "4.0.15-260422";

  src = pkgs.fetchurl {
    url = vars.xppenDriverUrl;
    sha256 = "sha256-QUzJ/7mFVSDTGHS3Z5IEcok68GkrefhR82wm3CiUrss=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    glib
    dbus
    libusb1
    fontconfig
    freetype
    zlib
    libGL
    libsm
    libxext
    libxtst
    libx11
    libxrender
    libxcb
    libXi
    libxrandr
    libxinerama
    libxcursor
    xkeyboard_config
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    mkdir -p temp_unpack
    dpkg-deb -x $src temp_unpack

    cp -a --no-preserve=ownership temp_unpack/usr/* $out/
    if [ -d "temp_unpack/lib" ]; then
      cp -a --no-preserve=ownership temp_unpack/lib $out/
    fi

    SCRIPT_PATH=$(find $out -name "PenTablet.sh" -type f | head -n 1)
    DRIVER_DIR=$(dirname "$SCRIPT_PATH")

    chmod a+x "$SCRIPT_PATH"

    mkdir -p $out/bin
    makeWrapper "$SCRIPT_PATH" $out/bin/pentablet \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}" \
      --prefix XKB_CONFIG_ROOT : "${pkgs.xkeyboard_config}/share/X11/xkb" \
      --set QT_XKB_CONFIG_ROOT "${pkgs.xkeyboard_config}/share/X11/xkb" \
      --set QT_QPA_PLATFORM xcb \
      --set QT_PLUGIN_PATH "$DRIVER_DIR" \
      --set QT_AUTO_SCREEN_SCALE_FACTOR 0 \
      --set QT_SCALE_FACTOR 1 \
      --run "cd $DRIVER_DIR" \
      --set QT_X11_NO_MITSHM 1
  '';
}
