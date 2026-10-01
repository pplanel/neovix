# Retro 82 colorscheme (dark only); not packaged in nixpkgs and untagged
# upstream, so it is pinned to a commit.
{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "retro-82.nvim";
  version = "0.3.0-unstable-2026-04-26";

  src = fetchFromGitHub {
    owner = "OldJobobo";
    repo = "retro-82.nvim";
    rev = "41b8c42ed0099eb43824903ef606a6b051d33505";
    hash = "sha256-q8bWww0nZb95/AfcSQnRsS+s5YlnXC9PpRbmObM8QU4=";
  };

  meta = {
    description = "High-contrast neon-coastline colorscheme for Neovim";
    homepage = "https://github.com/OldJobobo/retro-82.nvim";
    license = lib.licenses.cc0;
  };
}
