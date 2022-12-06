{
  description = "rpdf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/?ref=release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        name = "rpdf";
        src = builtins.readFile ./rga-pdf.sh;
        script = (pkgs.writeScriptBin name src).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });

        makeName = "makePdf";
        makePdf = pkgs.python3Packages.buildPythonPackage {
          pname = makeName;
          version = "1.0";
          src = ./.;
          propagatedBuildInputs = with pkgs.python3Packages; [
            reportlab
            pypdf2
            setuptools
            pillow
          ];
        };

        deps = with pkgs; [ jq ripgrep-all evince ];
      in rec {
        defaultPackage = packages.rga-pdf;
        defualtApp = packages.rga-pdf;
        packages.rga-pdf = pkgs.symlinkJoin {
          name = name;
          paths = [ script makePdf ] ++ deps;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

        packages.maker = pkgs.symlinkJoin {
          name = "makePdf";
          paths = [ makePdf ] ++ deps;
          buildInputs = [pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };
      }
    );
}
