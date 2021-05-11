{ pkgs ? import ./pkgs { }
}:

pkgs.mkShell {
  name = "hlwmrc";

  buildInputs = with pkgs; [
    herbstluftwm
    xorg.xorgserver # For Xephyr
    picom # For testing transparency
    feh # To set a background
  ];
}
