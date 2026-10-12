-- GroundControl dashboard. The plugin is not in this repo: it comes in through extraPlugins.
-- neovix loads this in the deferred stage when `features.groundcontrol = true`
-- (neovix.override { features.groundcontrol = true; extraPlugins = [ groundcontrol ]; }).
-- autostart = true needs the eager stage instead: the deferred stage runs after UIEnter,
-- so the autostart autocmd would be registered too late.
-- Only Pedro's own repos: the list src-sync keeps cloned (nix-darwin). Without the file, no filter.
local function src_sync_repos()
  local ok, lines = pcall(vim.fn.readfile, vim.fs.normalize("~/.config/nix-darwin/modules/darwin/src-sync-repos.txt"))
  if not ok then return nil end
  return vim.tbl_filter(function(l) return l ~= "" and not l:match("^%s*#") end, vim.tbl_map(vim.trim, lines))
end

require("groundcontrol").setup({
  roots = { "~/src" },
  only = src_sync_repos(),
  -- projects = {
  --   { path = "~/src/neovix", repo = "pplanel/neovix", workflow = "check", linear = { team = "PPL" } },
  -- },
  services = {
    {
      id = "cache",
      name = "nixcache",
      short = "nix",
      glyph = "database",
      url = "https://cache.nixos.org/nix-cache-info",
    },
  },
  autostart = false,
})

vim.keymap.set("n", "<leader>G", "<cmd>GroundControl<cr>", { desc = "GroundControl" })
