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
              pkgs.docker-compose
            ];
            shellHook = ''
                echo "Checking Bitwarden status…"
                bw status --raw | grep -q '"unauthenticated"' && bw login < /dev/tty
                export BW_SESSION="$(bw unlock --raw < /dev/tty)"

                bw sync
                novops load -s .envrc && source .envrc
            '';
          };
        };
      }
    );
}
