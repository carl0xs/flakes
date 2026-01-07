{
  description = "Elixir + PostgreSQL development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        elixirVersion = pkgs.beam.packages.erlang_26.elixir_1_16;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            elixirVersion
            pkgs.postgresql_16
            pkgs.inotify-tools
            pkgs.nodejs_20
            pkgs.glibcLocales
            pkgs.elixir-ls
          ];

          shellHook = ''
            export PGDATA="$PWD/.postgres_data"
            export PGHOST="$PWD/.postgres"
            export LOG_PATH="$PWD/.postgres/LOG"

            mkdir -p "$PGHOST" "$PGDATA"

            if [ ! -d "$PGDATA/base" ]; then
              initdb --auth=trust --no-locale --encoding=UTF8

              pg_ctl start -l "$LOG_PATH" -o "-k $PGHOST"
              createdb postgres
              psql -h "$PGHOST" -d postgres -c "CREATE ROLE postgres WITH SUPERUSER LOGIN;"
              pg_ctl stop
            fi

            if ! pg_ctl status; then
              pg_ctl start -l "$LOG_PATH" -o "-k $PGHOST"
              echo "PostgreSQL started on socket: $PGHOST"
            fi

            # Elixir / Erlang
            export ERL_AFLAGS="-kernel shell_history enabled"
            export LANG="en_US.UTF-8"
            export LC_ALL="en_US.UTF-8"

            echo "Elixir + PostgreSQL development environment ready!"
            echo "PostgreSQL socket: $PGHOST"
          '';
        };

        apps.clean-postgres = {
          type = "app";
          program = toString (pkgs.writeShellScript "clean-postgres" ''
            pg_ctl -D "$PWD/.postgres_data" stop || true
            rm -rf "$PWD/.postgres_data" "$PWD/.postgres"
          '');
        };
      }
    );
}

