{
  description = "Dev environment with pnpm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
					config = {
						allowUnfree = true;
          	allowUnfreePredicate = _: true;
					};
        };

        nodejs = pkgs.nodejs_20;  
      in {
        devShell = pkgs.mkShell {
          buildInputs = [
						pkgs.pnpm
						pkgs.typescript-language-server
						nodejs
          ];
        };
      }
    );
}

