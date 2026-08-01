{
  description = "Thorium using Nix Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    {
      packages.x86_64-linux = {
        thorium =
          let
            pkgs = import nixpkgs { system = "x86_64-linux"; };
            pname = "thorium";
            version = "M150.0.7871.101";
            src = pkgs.fetchurl {
              url = "https://github.com/gz83/thorium/releases/download/M150.0.7871.101/Thorium_Browser_150.0.7871.101_AVX2.AppImage";
              sha256 = "sha256-J+xR8aCn18sag7AEJlmudN7vionTNotIUjlFqJK4FpM=";
            };
            appimageContents = pkgs.appimageTools.extractType2 {
              inherit pname src version;
            };
          in
          pkgs.appimageTools.wrapType2 {
            inherit pname version src;
            extraInstallCommands = ''
              install -m 444 -D ${appimageContents}/thorium-browser.desktop $out/share/applications/thorium-browser.desktop
              install -m 444 -D ${appimageContents}/thorium-browser.png $out/share/icons/hicolor/512x512/apps/thorium-browser.png
              substituteInPlace $out/share/applications/thorium-browser.desktop \
              --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
            '';
          };
        # AVX is compatible with most CPUs
        default = self.packages.x86_64-linux.thorium;
      };

      apps.x86_64-linux = {
        thorium = {
          type = "app";
          program = "${self.packages.x86_64-linux.thorium}/bin/thorium";
        };

        default = self.apps.x86_64-linux.thorium;
      };
    };
}
