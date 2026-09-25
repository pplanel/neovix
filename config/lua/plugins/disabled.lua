return {
  -- Sever mason dependency from core LazyVim plugins
  { "neovim/nvim-lspconfig", dependencies = {} },
  { "stevearc/conform.nvim", dependencies = {} },

  -- Explicitly disable all Mason plugins
  { "mason-org/mason.nvim", enabled = false },
  { "mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
  { "mason-nvim-dap.nvim", enabled = false },

  -- Explicitly disable MCP-Hub
  { "ravitemer/mcphub.nvim", enabled = false },
  { "mcphub.nvim", enabled = false },
}
