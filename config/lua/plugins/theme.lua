-- OneDark (navarasu) in its "deep" variant: darker navy background than the
-- default. setup() must run before the colorscheme so the style takes effect.
require("onedark").setup({ style = "deep" })

-- Kanagawa: plugin/Snacks highlights from the author's PR (config/kanagawa_highlights.lua),
-- applied through `overrides` because the plugin lives in the read-only Nix store. The
-- dashboard header is then repainted yellow (the PR makes it red). Like onedark, setup()
-- must precede the colorscheme.
require("kanagawa").setup({
  overrides = function(colors)
    local hl = require("config.kanagawa_highlights").setup(colors)
    hl.SnacksDashboardHeader = { fg = colors.theme.syn.identifier, bold = true }
    return hl
  end,
})

-- The last colorscheme picked (<leader>uC / <leader>FC) is saved outside the
-- Nix store and restored here, so switching themes needs no rebuild. OneDark
-- is the fallback when nothing is saved or the saved scheme is gone.
local state_file = vim.fn.stdpath("state") .. "/neovix/colorscheme"

local ok, lines = pcall(vim.fn.readfile, state_file)
local saved = ok and lines[1] or nil
if not (saved and pcall(vim.cmd.colorscheme, saved)) then require("onedark").load() end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("neovix_colorscheme", { clear = true }),
  callback = function(ev)
    vim.fn.mkdir(vim.fs.dirname(state_file), "p")
    vim.fn.writefile({ ev.match }, state_file)
  end,
})
