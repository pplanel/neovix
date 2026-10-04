# GitHub Actions workflow manager for Neovim; not packaged in nixpkgs.
{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "github-actions.nvim";
  version = "0.1.0-unstable-2026-08-24";

  src = fetchFromGitHub {
    owner = "skanehira";
    repo = "github-actions.nvim";
    rev = "340ab91f11643f76eaf854ede398e54769cccd4a";
    hash = "sha256-W8375avYiUkrAH/8E8x21n4xXzR0k9sSGbsRo186m2s=";
  };

  meta = {
    description = "Manage GitHub Actions workflows directly from Neovim";
    homepage = "https://github.com/skanehira/github-actions.nvim";
    license = lib.licenses.mit;
  };
}
