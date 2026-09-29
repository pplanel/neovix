{
  default = final: _prev: {
    neovix = final.callPackage ../../src/neovim/package.nix {};
    neovim = final.neovix;
  };
}
