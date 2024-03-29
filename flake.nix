{
  description = "Git hooks environment";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # Fetched via https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=terraform
  inputs.terraform_1_5_7-nixpkgs.url = "github:nixos/nixpkgs/4ab8a3de296914f3b631121e9ce3884f1d34e1e5";

  outputs = { self, nixpkgs, flake-utils, terraform_1_5_7-nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # Required for latest Terraform..
        };
        platform-env =  pkgs.symlinkJoin {
          name = "git-hooks-platform-env";
          paths = [
            pkgs.actionlint
            pkgs.golangci-lint
            pkgs.gotest
            pkgs.hadolint
            pkgs.lefthook
            pkgs.nodePackages.prettier
            pkgs.nodejs_20
            pkgs.shellcheck
            pkgs.shfmt
            terraform_1_5_7-nixpkgs.legacyPackages.${system}.terraform
            pkgs.tflint
            pkgs.trufflehog
            pkgs.yamllint
          ];
          # symlinkJoin can't handle symlinked dirs and nodePackages,
          # thus symlink ./bin -> ./lib/node_modules/.bin/.
          postBuild = ''
            for f in $out/lib/node_modules/.bin/*; do
              path="$(readlink --canonicalize-missing "$f")"
              ln -s "$path" "$out/bin/$(basename $f)"
            done
          '';
        };
      in {
        packages = {
          default = platform-env;
          git-hooks-platform-env = platform-env;
        };
      });
}