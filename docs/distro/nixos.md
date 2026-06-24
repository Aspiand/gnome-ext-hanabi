# Installation Guide for NixOS

## GNOME Version & Branch Selection

This flake targets the **`javascript` branch** (GNOME 45–50, X11 + Wayland).

For **GNOME 50+** (Wayland only), the upstream `typescript` branch is used. To switch:

```nix
hanabi = {
  url = "github:Aspiand/gnome-ext-hanabi?ref=draft/nix-typescript";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

> **Note:** The `typescript` branch requires `nodejs` and `npm` as build dependencies. The flake handles this automatically when the source tree includes `package.json` with a build script.

| GNOME Version | Flake Branch | Upstream Branch | Wayland | X11 |
|---|---|---|---|---|
| 42–44 | `legacy` (not packaged) | `legacy` | ❌ | ✅ |
| 45–50 | `draft/nix` | `javascript` | ✅ | ✅ |
| 50+ | `draft/nix-typescript` | `typescript` | ✅ | ❌ |

---

## Prerequisites

- NixOS with flakes enabled
- Hardware video acceleration (Intel/AMD) for best performance

---

## 1. Flake Input

Add Hanabi as a flake input:

```nix
# flake.nix
{
  inputs = {
    hanabi = {
      url = "github:Aspiand/gnome-ext-hanabi?ref=draft/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

---

## 2. Enable the Extension

### With home-manager (recommended)

Add the package and enable the extension in your home configuration:

```nix
# home.nix
{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.hanabi.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        (inputs.hanabi.packages.${pkgs.stdenv.hostPlatform.system}.default).passthru.extensionUuid
      ];
    };
  };
}
```

### With NixOS system packages

```nix
# configuration.nix
{ inputs, pkgs, ... }: {
  environment.systemPackages = [
    inputs.hanabi.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

---

## 3. GStreamer & VA-API

For hardware-accelerated video playback, enable VA-API in your NixOS config:

```nix
# configuration.nix
{
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver   # Intel
      vaapiIntel           # Older Intel
      vaapiVdpau           # NVIDIA
      nvidia-vaapi-driver  # NVIDIA (Wayland)
    ];
  };
}
```

If video doesn't play, ensure GStreamer VAAPI is available:

```bash
# Check VA-API support
gst-inspect-1.0 vaapi
```

---

## 4. GTK4 Media Backend

Hanabi requires the GTK4 GStreamer media backend (`gtk4paintablesink`). On NixOS this is included automatically when `gtk4` is in `buildInputs`. No extra steps needed.

---

## 5. Troubleshooting

| Symptom | Fix |
|---|---|
| **Video doesn't play / blank wallpaper** | Check GStreamer: `gst-inspect-1.0 gtk4paintablesink`. If missing, rebuild. |
| **High CPU usage (NVIDIA)** | Clear GStreamer cache: `rm -rf ~/.cache/gstreamer-1.0/`. Run `gst-inspect-1.0 nvcodec` to verify. |
| **Extension not detected** | Verify UUID matches: `ls ~/.local/share/gnome-shell/extensions/` or check system extensions: `ls /run/current-system/sw/share/gnome-shell/extensions/`. |
| **Schema not found** | Ensure `wrapGAppsHook4` ran in postFixup. Check schema symlink: `readlink /run/current-system/sw/share/gnome-shell/extensions/hanabi-extension@jeffshee.github.io/schemas`. |
| **"Blur My Shell" makes wallpaper transparent** | Add `io.github.jeffshee.HanabiRenderer` to Blur My Shell → Applications blur → Blacklist. |

---

## 6. Updating

```bash
nix flake lock --update-input hanabi
nixos-rebuild switch --flake .#
```

---

## References

- [Hanabi GitHub](https://github.com/jeffshee/gnome-ext-hanabi)
- [NixOS Discourse — GNOME Extension Hanabi on NixOS](https://discourse.nixos.org/t/gnome-extention-hanabi-on-nixos/36750)
- [Nixpkgs GNOME Packaging Guide](https://ryantm.github.io/nixpkgs/languages-frameworks/gnome/)
