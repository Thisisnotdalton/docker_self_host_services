{
  description = "Flake using Novops";

  inputs = {
    novops.url = "github:PierreBeucher/novops";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, novops, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        novopsPackage = novops.packages.${system}.novops;
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = [
              novopsPackage
              pkgs.bitwarden-cli
            ];
            shellHook = ''
              # Run novops on shell startup
              novops load -s .envrc && source .envrc
            '';
          };
        };
      }
    );
}
