{
  description = "Hanabi - Live Wallpaper for GNOME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Version from the source repo itself
      version =
        if self ? lastModifiedDate && self ? shortRev then
          "${builtins.substring 0 8 self.lastModifiedDate}-${self.shortRev}"
        else
          "unstable";

      hanabiPackage = pkgs:
        pkgs.callPackage ./nix/package.nix {
          src = self.outPath;
          inherit version;
        };
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = hanabiPackage pkgs;
          hanabi = hanabiPackage pkgs;
        }
      );

      overlays.default = final: _: {
        hanabi = final.callPackage ./nix/package.nix {
          src = self.outPath;
          inherit version;
        };
      };
    };
}
