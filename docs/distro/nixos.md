# NixOS Installation Guide

## Using Flakes

```bash
nix build github:Aspiand/gnome-ext-hanabi/draft/nix-packaging#hanabi
```

Or as a flake input:

```nix
{
  inputs.hanabi.url = "github:Aspiand/gnome-ext-hanabi/draft/nix-packaging";

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

## Without Flakes

```bash
nix-build -E 'with import <nixpkgs> {}; callPackage ./. {}'
```

Or via the repo directory directly (requires `default.nix` — not yet available in this branch).

## Home Manager

Reference: [aira's home.nix](/host/dotfiles/nixos/hosts/aira/home.nix)

Add to `home.packages`:

```nix
# system flake overlay provides pkgs.hanabi
home.packages = with pkgs; [ hanabi ];
```

Then enable the extension via dconf:

```nix
dconf.settings = {
  "org/gnome/shell" = {
    enable-extensions = true;
    enabled-extensions = [
      pkgs.hanabi.extensionUuid
    ];
  };
};
```

The `extensionUuid` passthru is `hanabi-extension@jeffshee.github.io`.
