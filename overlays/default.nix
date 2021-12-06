self: super:
let
  sources = import ../nix/sources.nix;
in
{
  herbstluftwm = super.herbstluftwm.overrideAttrs (orig: {
    version = "git-${builtins.substring 0 7 sources.herbstluftwm.rev}";
    src = sources.herbstluftwm;

    # Disable the tests.  They take forever and then some weird
    # threading issue kills them off with a horrible backtrace.
    doCheck = false;

    # Python is used during the build process to generate the
    # documentation.
    buildInputs =
      orig.buildInputs ++
      [ super.python3 ];

    # Force full version of asciidoc since building from Git needs
    # to use xsltproc:
    depsBuildBuild = [ super.asciidoc-full ];

    # Additional patching for Git version:
    postPatch = orig.postPatch + ''
      patchShebangs doc/format-doc.py
    '';
  });
}

