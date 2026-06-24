# NixOS Installation Guide

## Flake input

Add Hanabi as a flake input:

```nix
{
  inputs.hanabi.url = "github:Aspiand/gnome-ext-hanabi";
}
```

## NixOS system configuration

### Using overlay (recommended)

Apply the overlay and add `hanabi` to system packages:

```nix
{
  inputs.hanabi.url = "github:Aspiand/gnome-ext-hanabi";

  outputs = { self, nixpkgs, hanabi, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ hanabi.overlays.default ];
          environment.systemPackages = [ pkgs.hanabi ];
        })
      ];
    };
  };
}
```

### Direct package reference

Without overlay, reference the package directly:

```nix
{ pkgs, hanabi, ... }: {
  environment.systemPackages = [ hanabi.packages.${pkgs.system}.hanabi ];
}
```

After rebuilding, enable the extension via CLI:

```bash
gnome-extensions enable hanabi-extension@jeffshee.github.io
```

Or using GNOME Extensions app.

## Home Manager

### Via system overlay (simplest)

If Hanabi is already in `environment.systemPackages` through the system flake, Home Manager only needs to enable the extension:

```nix
{ pkgs, ... }: {
  programs.gnome-shell.enable = true;
  programs.gnome-shell.extensions = [ pkgs.hanabi ];
}
```

Alternatively with dconf:

```nix
{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell" = {
      enable-extensions = true;
      enabled-extensions = [ pkgs.hanabi.extensionUuid ];
    };
  };
}
```

### Standalone (without system overlay)

Reference the flake package directly within Home Manager:

```nix
{ pkgs, inputs, ... }: {
  home.packages = [ inputs.hanabi.packages.${pkgs.system}.hanabi ];

  programs.gnome-shell.enable = true;
  programs.gnome-shell.extensions = [ inputs.hanabi.packages.${pkgs.system}.hanabi ];
}
```

## Extension UUID

`hanabi-extension@jeffshee.github.io`

Available programmatically as `pkgs.hanabi.extensionUuid`.

## Post-install

1. Restart GNOME Shell: <kbd>Alt</kbd>+<kbd>F2</kbd>, type `r`, press <kbd>Enter</kbd>
2. Enable Hanabi in GNOME Extensions app
3. Open extension preferences and select your wallpaper

See [main README](../../README.md#troubleshooting) for troubleshooting.
