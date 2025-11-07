{
  inputs = {
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ flake-parts, systems, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = import systems;

        imports = [ inputs.treefmt-nix.flakeModule ];

        perSystem =
          _:
          {
            treefmt.programs = {
              actionlint.enable = true;
              deadnix.enable = true;
              jsonfmt.enable = true;
              mdformat.enable = true;
              nixfmt = {
                enable = true;
                strict = true;
              };
              oxipng.enable = true;
              statix.enable = true;
            };
          };
      }
    );
}
