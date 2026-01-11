{
  description = "Thorium using Nix Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    packages.x86_64-linux = {
      thorium = let
        pkgs = import nixpkgs {system = "x86_64-linux";};
        name = "thorium";
        version = "M138.0.7204.300 - 64";
        src = pkgs.fetchurl {
          url = "https://github.com/Alex313031/thorium/releases/download/M138.0.7204.300/Thorium_Browser_138.0.7204.300_AVX2.AppImage";
          sha256 = "sha256-vpAAoZv8Ayg1AN0Uo9Ou8fX22hdhJnxHM1W6XrpwMww=";
        };
        appimageContents = pkgs.appimageTools.extractType2 {inherit name src;};
      in
        pkgs.appimageTools.wrapType2 {
          inherit name version src;
          extraInstallCommands = ''
            install -m 444 -D ${appimageContents}/thorium-browser.desktop $out/share/applications/thorium-browser.desktop
            install -m 444 -D ${appimageContents}/thorium.png $out/share/icons/hicolor/512x512/apps/thorium.png
            substituteInPlace $out/share/applications/thorium-browser.desktop \
            --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${name} %U'
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
