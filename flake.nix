{
  description = "Standalone Neovim Flake with bundled Nixpkgs toolchains";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        neovimPkg = pkgs.callPackage ./default.nix { };
      in
      {
        packages.default = neovimPkg;
        packages.neovim = neovimPkg;

        apps.default = {
          type = "app";
          program = "${neovimPkg}/bin/nvim";
        };

        devShells.default = pkgs.mkShell {
          packages = [ neovimPkg ];
        };
      }
    )
    // {
      overlays.default = final: prev: {
        neovim = final.callPackage ./default.nix { };
      };
    };
}
