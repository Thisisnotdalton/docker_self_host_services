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
        STAGE = let s = builtins.getEnv "STAGE"; in if s == "" then "dev" else s;
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = [
              novopsPackage
              pkgs.bitwarden-cli
              pkgs.docker-compose
            ];
            shellHook = ''
                export STAGE=${STAGE}
                echo "Loading Novops environment for stage: ${STAGE}"
                export STAGE_DIR="novops/stages/${STAGE}"
                echo "Checking Bitwarden status…"
                bw status --raw | grep -q '"unauthenticated"' && bw login < /dev/tty
                export BW_SESSION="$(bw unlock --raw < /dev/tty)"
                bw sync
                if [ -d "$STAGE_DIR" ]; then
                    for f in "$STAGE_DIR"/*.yml; do
                        source <(novops load -c $f -e ${STAGE})
                    done
                else
                    echo "Stage directory not found: $STAGE_DIR"
                    return 1
                fi
            '';
          };
        };
      }
    );
}
