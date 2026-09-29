{packages}: let
  nvim = {
    type = "app";
    program = "${packages.neovim}/bin/nvim";
    meta.description = "Launch neovix";
  };
in {
  default = nvim;
  neovim = nvim;
}
