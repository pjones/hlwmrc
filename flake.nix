{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    herbstluftwm = {
      url = "github:/herbstluftwm/herbstluftwm";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, herbstluftwm, ... }:
    let
      # List of supported systems:
      supportedSystems = [
        "aarch64-linux"
        "armv7l-linux"
        "i686-linux"
        "x86_64-linux"
      ];

      # Function to generate a set based on supported systems:
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      overlays.default = final: prev: {
        herbstluftwm = self.packages.${prev.system}.herbstluftwm;

        pjones = (prev.pjones or { }) // {
          hlwmrc = self.packages.${prev.system}.hlwmrc;
        };
      };

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        {
          herbstluftwm = pkgs.herbstluftwm;

          herbstluftwm_git =
            pkgs.herbstluftwm.overrideAttrs (orig: {
              version = "git";
              src = herbstluftwm;

              # Disable the tests.  They take forever and then some weird
              # threading issue kills them off with a horrible backtrace.
              doCheck = false;

              # Python is used during the build process to generate the
              # documentation.
              buildInputs = orig.buildInputs ++ [ pkgs.python3 ];

              # Additional patching for Git version:
              postPatch = orig.postPatch + ''
                patchShebangs doc/format-doc.py
              '';
            });

          hlwmrc =
            let herbstluftwm = self.packages.${system}.herbstluftwm; in
            pkgs.stdenvNoCC.mkDerivation {
              name = "hlwmrc";
              meta.description = "Peter's herbstluftwm configuration.";
              src = self;

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

                export herbstluftwm="${herbstluftwm}/bin/herbstluftwm"
                substituteAll libexec/hlwmrc "$out/libexec/hlwmrc"
                chmod 0555 "$out/libexec/hlwmrc"
              '';
            };

          default = self.packages.${system}.hlwmrc;
        });

      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          buildInputs = with nixpkgsFor.${system}; [
            xorg.xorgserver # For Xephyr
            picom # For testing transparency
            feh # To set a background
          ];
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
    };
}
