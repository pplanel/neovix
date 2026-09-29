# Shell for hacking on neovix itself: the wrapped nvim reads Lua straight from
# the working tree (NEOVIX_CONFIG), so config edits apply on the next launch
# without a rebuild.
{
  mkShell,
  neovim,
  alejandra,
  statix,
  stylua,
  lua-language-server,
}:
mkShell {
  packages = [neovim alejandra statix stylua lua-language-server];

  shellHook = ''
    export NEOVIX_CONFIG="$PWD/config"
    echo "neovix: config live-loaded from $NEOVIX_CONFIG"
  '';
}
