# Runs smoke.lua inside the built package with a throwaway HOME.
{
  runCommand,
  neovim,
}:
runCommand "neovix-smoke" {nativeBuildInputs = [neovim];} ''
  set -o pipefail
  export HOME=$(mktemp -d)
  export XDG_CONFIG_HOME=$HOME/.config XDG_DATA_HOME=$HOME/.local/share \
         XDG_STATE_HOME=$HOME/.local/state XDG_CACHE_HOME=$HOME/.cache
  nvim --headless -c "luafile ${./smoke.lua}" 2>&1 | tee $out
''
