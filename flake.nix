{
  description = "Hanabi - Live Wallpaper for GNOME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      version = (builtins.fromJSON (builtins.readFile ./package.json)).version;

      extensionUuid = "hanabi-extension@jeffshee.github.io";

      mkHanabi =
        pkgs:
        let
          pname = "gnome-ext-hanabi";
        in
        pkgs.stdenv.mkDerivation {
          inherit pname version;
          src = self.outPath;

          nativeBuildInputs = with pkgs; [
            meson
            ninja
            glib
            nodejs
            wrapGAppsHook4
            appstream-glib
            gobject-introspection
            shared-mime-info
          ];

          buildInputs = with pkgs; [
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

          meta = with pkgs.lib; {
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
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          hanabi = mkHanabi (import nixpkgs { inherit system; });
        in
        {
          inherit hanabi;
          default = hanabi;
        }
      );

      overlays.default = final: _: {
        hanabi = mkHanabi final;
      };
    };
}
