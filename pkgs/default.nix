let sources = import ../nix/sources.nix;
in
{ pkgs ? import sources.nixpkgs { }
}:
pkgs.appendOverlays [ (import ../overlays) ]
