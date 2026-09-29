-- neovix entrypoint. Every plugin is already on the runtimepath (installed by
-- Nix into the packpath), so "loading" is just calling setup, staged so the
-- first frame paints before the heavy modules run.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")

local function load(name)
  local ok, err = pcall(require, name)
  if not ok then
    vim.schedule(function() vim.notify(("neovix: failed to load %s\n%s"):format(name, err), vim.log.levels.ERROR) end)
  end
end

-- 1. Eager: anything that shapes the first frame, or must be in place before
--    a file passed on the command line runs its FileType autocmds.
for _, name in ipairs({
  "plugins.theme",
  "plugins.ui",
  "plugins.editor",
  "plugins.tree",
  "plugins.treesitter",
  "plugins.lsp",
  "plugins.format",
  "plugins.rust",
  "plugins.markdown",
}) do
  load(name)
end
require("config.keymaps")
require("config.autocmds")

-- 2. Deferred: completion and tools, right after the UI is up. Completion
--    goes first so CodeCompanion finds blink.cmp configured when it registers
--    its chat source.
local deferred = { "plugins.completion", "plugins.ai", "plugins.dap", "plugins.testing" }

if #vim.api.nvim_list_uis() == 0 then
  -- Headless (scripts, `nix flake check`): no UI to wait for, load everything.
  vim.tbl_map(load, deferred)
  return
end

vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.g.neovix_startuptime = (vim.uv.hrtime() - vim.g.neovix_start) / 1e6
    vim.schedule(function() vim.tbl_map(load, deferred) end)
  end,
})
