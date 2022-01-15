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

        deps = with pkgs; [ jq ripgrep-all evince ];
      in rec {
        defaultPackage = packages.rga-pdf;
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
