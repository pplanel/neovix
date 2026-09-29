{
  pkgs,
  packages,
}: {
  inherit (packages) neovim;
  smoke = pkgs.callPackage ../../src/neovim/checks/smoke.nix {inherit (packages) neovim;};
}
