self: super:
let
  sources = import ../nix/sources.nix;
in
{
  herbstluftwm = super.herbstluftwm;
}
