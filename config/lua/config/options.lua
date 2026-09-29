local opt = vim.opt
local icons = require("config.icons")

vim.g.autoformat = true -- format on save; toggle with <leader>uf / <leader>uF

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.laststatus = 3 -- one global statusline
opt.showmode = false -- lualine shows it
opt.ruler = false
opt.cmdheight = 1
opt.pumheight = 10
opt.pumblend = 10
opt.winminwidth = 5
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.list = true
opt.fillchars = {
  foldopen = icons.ui.chevron_down,
  foldclose = icons.ui.chevron_right,
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.winborder = "rounded"
opt.smoothscroll = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.shiftround = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "nosplit"
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.mouse = "a"
opt.confirm = true
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.timeoutlen = 300
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.completeopt = "menu,menuone,noselect"
opt.jumpoptions = "view"
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.spelllang = { "en" }

-- Treesitter folds, all open by default (see autocmds.lua for foldexpr).
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldtext = ""

vim.diagnostic.config({
  update_in_insert = true,
  severity_sort = true,
  underline = true,
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
    },
  },
})
