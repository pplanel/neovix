{
  pkgs,
  packages,
}: {
  default = pkgs.callPackage ../../src/neovim/devshell.nix {inherit (packages) neovim;};
}
