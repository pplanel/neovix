{pkgs}: let
  neovim = pkgs.callPackage ../../src/neovim/package.nix {};
in {
  inherit neovim;
  default = neovim;
  # Exposed so the binary cache workflow builds and publishes it: the default
  # neovim leaves the groundcontrol feature off, so it isn't in that closure.
  linear-cli = pkgs.callPackage ../../src/neovim/pkgs/linear-cli.nix {};
}
