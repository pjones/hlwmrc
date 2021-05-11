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
    mkdir -p "$out/bin" "$out/sbin" "$out/scripts" "$out/config"

    for f in scripts/*; do
      install -m0555 "$f" "$out/scripts"
    done

    for f in config/*; do
      install -m0555 "$f" "$out/config"
    done

    export herbstluftwm="${herbstluftwm}/bin/herbstluftwm"
    substituteAll sbin/hlwmrc "$out/sbin/hlwmrc"
    (cd "$out/bin" && ln -s "${herbstluftwm}/bin/herbstclient" .)
  '';
}
