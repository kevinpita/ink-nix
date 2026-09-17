{
  description = "Nix package for ink, a terminal Markdown reader";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ink = pkgs.callPackage ./package.nix { };
        in
        {
          inherit ink;
          default = ink;
        }
      );

      checks = forAllSystems (system: {
        inherit (self.packages.${system}) ink;
      });

      overlays.default = final: _prev: {
        ink = final.callPackage ./package.nix { };
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
