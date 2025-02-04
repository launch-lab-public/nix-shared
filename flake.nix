{
  description = "Shared Nix definitions for a development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
      ...
    }:
    let
      # Needed for bitwarden-cli: https://github.com/NixOS/nixpkgs/issues/339576
      bitwardenOverlay = final: prev: {
        bitwarden-cli = prev.bitwarden-cli.overrideAttrs (oldAttrs: {
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
            prev.llvmPackages_18.stdenv.cc
          ];
          stdenv = prev.llvmPackages_18.stdenv;
        });
      };

      project =
        pkgsConfig: f:
        flake-utils.lib.eachDefaultSystem (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config = pkgsConfig;
            };

            unstablePkgs = import nixpkgs-unstable {
              inherit system;
              overlays = [ bitwardenOverlay ];
            };

            pkgsWithUnstable = pkgs // {
              unstable = unstablePkgs;
            };
          in
          (f pkgsWithUnstable)
          // {
            formatter = pkgs.nixfmt-rfc-style;
          }
        );
    in
    {
      inherit project;
    }
    // project { } (pkgs: {
      devShell = pkgs.mkShell {
        buildInputs = [ ];
      };
    });
}
