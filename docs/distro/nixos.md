# Installation Guide for NixOS

Add to your flake inputs:

```nix
hanabi = {
  url = "github:jeffshee/gnome-ext-hanabi";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

## Enable Extension

```nix
{ inputs, pkgs, ... }:
let hanabi = inputs.hanabi.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  home.packages = [ hanabi ];

  dconf.settings."org/gnome/shell".enabled-extensions = [
    hanabi.passthru.extensionUuid
  ];
}
```

Or `environment.systemPackages` if not using home-manager.

## Troubleshooting

| Problem | Fix |
|---|---|
| Video blank | `rm -rf ~/.cache/gstreamer-1.0/` |
| High CPU (NVIDIA) | `gst-inspect-1.0 nvcodec` |
| Blurry wallpaper | Blacklist `io.github.jeffshee.HanabiRenderer` in Blur My Shell |

## Update

```bash
nix flake lock --update-input hanabi
```
