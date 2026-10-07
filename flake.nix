{
  description = "Homepage for synthetica.be";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    inputs:
    let
      overlay = final: prev: {
        haskell = prev.haskell // {
          packageOverrides =
            hfinal: hprev:
            prev.haskell.packageOverrides hfinal hprev
            // {
              synthetica-homepage = hfinal.callCabal2nix "synthetica-homepage" ./. { };
            };
        };
        synthetica-homepage = final.haskell.lib.compose.justStaticExecutables final.haskellPackages.synthetica-homepage;
        pages = final.runCommand "page" { nativeBuildInputs = [final.synthetica-homepage]; } ''
          cp --no-preserve=mode -r ${final.synthetica-homepage.src} src
          cd src
          synthetica-homepage-exe rebuild
          cp -r _site $out
        '';
      };
      perSystem =
        system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
          hspkgs = pkgs.haskellPackages;
        in
        {
          devShell = hspkgs.shellFor {
            withHoogle = true;
            packages = p: [ p.synthetica-homepage ];
            buildInputs = [
              hspkgs.cabal-install
              hspkgs.haskell-language-server
              hspkgs.hlint
              hspkgs.ormolu
              pkgs.bashInteractive
            ];
          };
          packages = { inherit (pkgs) synthetica-homepage pages; };
          defaultPackage = pkgs.synthetica-homepage;
        };
    in
    { inherit overlay; } // inputs.flake-utils.lib.eachDefaultSystem perSystem;
}
