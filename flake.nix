{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = [
              pkgs.novops
              pkgs.bitwarden-cli
              pkgs.docker-compose
              pkgs.jq
            ];
            shellHook = ''
                : "''${STAGE:=dev}"
                export STAGE
                echo "Loading Novops environment for stage: ''${STAGE}"

                export STAGE_DIR="stages/$STAGE/"
                export NOVOPS_DIR="$STAGE_DIR/novops_secrets"
                echo "Checking Bitwarden status…"
                bw status --raw | grep -q '"unauthenticated"' && bw login < /dev/tty
                export BW_SESSION="$(bw unlock --raw < /dev/tty)"
                bw sync
                if [ -d "$NOVOPS_DIR" ]; then
                    for f in "$NOVOPS_DIR"/*.yml; do
                        source <(novops load -c "$f" -e "$STAGE")
                    done
                else
                    echo "Novops stage directory not found: $NOVOPS_DIR"
                    return 1
                fi
            '';
          };
        };
      }
    );
}
