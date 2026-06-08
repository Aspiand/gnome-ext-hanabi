# Installation Guide for NixOS

The Hanabi extension is packaged as a Nix flake, using the repository itself as the source.

## Quick Build

```bash
# Clone and build
git clone https://github.com/Aspiand/gnome-ext-hanabi.git
cd gnome-ext-hanabi
nix build .#hanabi

# Or directly from GitHub
nix build github:Aspiand/gnome-ext-hanabi/draft/nix-packaging#hanabi
```

The built extension lands in `result/share/gnome-shell/extensions/`.

## Using as a Flake Input

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hanabi.url = "github:Aspiand/gnome-ext-hanabi/draft/nix-packaging";
    hanabi.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, hanabi, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ hanabi.overlays.default ];
      };
    in {
      # Now pkgs.hanabi is available
      environment.systemPackages = with pkgs; [ hanabi ];
    };
}
```

## Using via Overlay

The flake exposes an overlay:

```nix
nixpkgs.overlays = [
  (import ./path/to/hanabi-flake).overlays.default
];
```

This adds `pkgs.hanabi` to the package set.

## GNOME Shell Versions

Each GNOME version branch has matching flake support:

| Branch       | GNOME Versions | How to Build                           |
|--------------|---------------|----------------------------------------|
| `master`     | 45–50         | `nix build .#hanabi`                   |
| `gnome-50`   | 50            | `nix build github:.../gnome-50#hanabi` |
| `gnome-49`   | 49            | `nix build github:.../gnome-49#hanabi` |
| `gnome-48`   | 48            | `nix build github:.../gnome-48#hanabi` |
| `gnome-47`   | 47            | `nix build github:.../gnome-47#hanabi` |
| `gnome-46`   | 46            | `nix build github:.../gnome-46#hanabi` |

## Dependencies

All dependencies are handled by Nix automatically:

- **GStreamer** suite (base, good, bad, ugly, libav, vaapi)
- **Clapper** (hardware-accelerated playback)
- **GJS** (GNOME JavaScript runtime)
- **GTK4** with GStreamer media backend
- **Wayland** protocols
- **Meson** + **Ninja** build system

## Auto-Updates

A GitHub Action runs weekly to update the `nixpkgs` hash in `flake.lock`.
It can also be triggered manually via `workflow_dispatch`.

## Troubleshooting

**Black screen after enabling extension:**
Enable `Force gtk4paintablesink` or `Force GtkMediaFile` in extension settings.

**Blur My Shell conflict:**
Add `io.github.jeffshee.HanabiRenderer` to Blur My Shell's application blacklist.
