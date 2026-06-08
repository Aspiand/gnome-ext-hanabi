{
  lib,
  stdenv,
  meson,
  ninja,
  glib,
  nodejs,
  wrapGAppsHook4,
  appstream-glib,
  gobject-introspection,
  shared-mime-info,
  gst_all_1,
  clapper,
  gjs,
  gtk4,
  wayland,
  wayland-protocols,

  src,
  version,
}:

let
  extensionName = "hanabi";
  extensionUuid = "hanabi-extension@jeffshee.github.io";
in

stdenv.mkDerivation rec {
  pname = "gnome-ext-hanabi";
  inherit version src;

  nativeBuildInputs = [
    meson
    ninja
    glib
    nodejs
    wrapGAppsHook4
    appstream-glib
    gobject-introspection
    shared-mime-info
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi
    clapper
    gjs
    gtk4
    glib
    wayland
    wayland-protocols
  ];

  dontWrapGApps = true;

  postPatch = ''
    patchShebangs build-aux/meson-postinstall.sh
  '';

  postFixup = ''
    wrapGApp "$out/share/gnome-shell/extensions/${extensionUuid}/renderer/renderer.js"

    ln -s "$out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas" \
      "$out/share/gnome-shell/extensions/${extensionUuid}/schemas"
  '';

  passthru = {
    inherit extensionName extensionUuid;
  };

  meta = with lib; {
    description = "GNOME Shell extension for animated video wallpapers";
    longDescription = ''
      Hanabi (花火, fireworks) is a GNOME Shell extension that lets you use any
      video or GIF as your desktop wallpaper. It supports both X11 and Wayland,
      and takes advantage of hardware-accelerated video playback via GStreamer
      and Clapper.
    '';
    homepage = "https://github.com/jeffshee/gnome-ext-hanabi";
    changelog = "https://github.com/jeffshee/gnome-ext-hanabi/releases";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
