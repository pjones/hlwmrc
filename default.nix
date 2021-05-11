let sources = import nix/sources.nix;
in
{ pkgs ? import sources.nixpkgs { }
}:
let
  herbstluftwm = (pkgs.appendOverlays [ (import ./overlays) ]).herbstluftwm;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "hlwmrc";
  meta.description = "Peter's herbstluftwm configuration.";
  src = ./.;

  phases = [
    "unpackPhase"
    "installPhase"
    "fixupPhase"
  ];

  installPhase = ''
    mkdir -p "$out/bin" "$out/libexec" "$out/config"

    for f in config/*; do
      install -m0555 "$f" "$out/config"
    done

    for f in bin/*; do
      install -m0555 "$f" "$out/bin"
    done

    (cd "$out/bin" && ln -s "${herbstluftwm}/bin/herbstclient" .)

    export herbstluftwm="${herbstluftwm}/bin/herbstluftwm"
    substituteAll libexec/hlwmrc "$out/libexec/hlwmrc"
    chmod 0555 "$out/libexec/hlwmrc"
  '';
}
