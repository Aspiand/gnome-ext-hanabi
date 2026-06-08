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

## Home Manager

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
