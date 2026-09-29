{pkgs}: let
  neovim = pkgs.callPackage ../../src/neovim/package.nix {};
in {
  inherit neovim;
  default = neovim;
}
