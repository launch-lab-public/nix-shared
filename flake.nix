{
  description = "Shared Nix definitions for a development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      project =
        pkgsConfig: f:
        flake-utils.lib.eachDefaultSystem (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config = pkgsConfig;
            };
          in
          (f pkgs)
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
