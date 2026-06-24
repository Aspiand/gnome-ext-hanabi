# Installation Guide for NixOS

## GNOME Version & Branch

| GNOME | Flake Branch | Upstream |
|---|---|---|
| 42–44 | — | `legacy` |
| 45–50 | `draft/nix` | `javascript` |
| 50+ | `draft/nix-typescript` | `typescript` |

```nix
# flake.nix
hanabi = {
  url = "github:jeffshee/gnome-ext-hanabi";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

## Enable Extension

```nix
# home.nix
{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.hanabi.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  dconf.settings."org/gnome/shell".enabled-extensions = [
    (inputs.hanabi.packages.${pkgs.stdenv.hostPlatform.system}.default).passthru.extensionUuid
  ];
}
```

Or via `environment.systemPackages` if not using home-manager.

## Troubleshooting

| Problem | Fix |
|---|---|
| Video blank | `rm -rf ~/.cache/gstreamer-1.0/` |
| High CPU (NVIDIA) | `gst-inspect-1.0 nvcodec` — check acceleration |
| Blurry wallpaper | Blacklist `io.github.jeffshee.HanabiRenderer` in Blur My Shell |

## Update

```bash
nix flake lock --update-input hanabi
nixos-rebuild switch --flake .#
```
