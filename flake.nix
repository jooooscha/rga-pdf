{
  description = "rpdf";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/?ref=release-21.11";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix = {
      url = "github:DavHau/mach-nix";
    };
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        name = "rpdf";
        src = builtins.readFile ./rga-pdf.sh;
        script = (pkgs.writeScriptBin name src).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });

        makeName = "makePdf";
        # makeSrc = builtins.readFile ./makePdf.py;
        makePdf = pkgs.python3Packages.buildPythonPackage {
          pname = makeName;
          version = "1.0";
          src = ./.;
          # propagatedBuildInputs = with pkgs.python39Packages; [ pypdf2 ];
          propagatedBuildInputs = with pkgs.python39Packages; [
            reportlab
            pypdf2
            setuptools
          ];
        };

        buildInputs = with pkgs; [ ];
      in rec {
        defaultPackage = packages.script;
        packages.script = pkgs.symlinkJoin {
          name = name;
          paths = [ script makePdf ] ++ buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

        packages.maker = pkgs.symlinkJoin {
          name = "makePdf";
          paths = [ makePdf ] ++ buildInputs;
          buildInputs = [pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };
      }
    );
}
