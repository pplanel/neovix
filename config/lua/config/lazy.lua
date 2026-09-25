local lazypath = vim.env.LAZY_PLUGINS and (vim.env.LAZY_PLUGINS .. "/lazy.nvim")
  or (vim.fn.stdpath("data") .. "/lazy/lazy.nvim")

if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
if vim.env.NEOVIM_CONFIG and not vim.g.lazyvim_json then
  vim.g.lazyvim_json = vim.env.NEOVIM_CONFIG .. "/lazyvim.json"
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local lazy_opts = {
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = false }, -- disable update checker when packaged via Nix
  performance = {
    rtp = {
      reset = false,
      paths = vim.env.NEOVIM_CONFIG and { vim.env.NEOVIM_CONFIG } or {},
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}

if vim.env.LAZY_PLUGINS then
  lazy_opts.dev = {
    path = vim.env.LAZY_PLUGINS,
    patterns = { "" },
    fallback = true,
  }
end

require("lazy").setup(lazy_opts)
