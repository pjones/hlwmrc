self: super:
let
  sources = import ../nix/sources.nix;

  # The nix expression for herbstluftwm from nixpkgs:
  herbstluftwm-unstable = "${sources.nixpkgs-unstable}/pkgs/applications/window-managers/herbstluftwm";
in
{
  # Pull in the bleeding-edge herbstluftwm from Git:
  herbstluftwm =
    (super.callPackage herbstluftwm-unstable { }).overrideAttrs (orig: {
      version = "git-${builtins.substring 0 7 sources.herbstluftwm.rev}";
      src = sources.herbstluftwm;

      # Force full version of asciidoc since building from Git needs
      # to use xsltproc:
      depsBuildBuild = [ super.asciidoc-full ];

      # Additional patching for Git version:
      postPatch = orig.postPatch + ''
        patchShebangs doc/format-doc.py
      '';
    });
}
