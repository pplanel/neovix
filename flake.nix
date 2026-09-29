{
  description = "neovix — a pure, Nix-managed Neovim distribution with bundled toolchains";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: import ./flake inputs;
}
