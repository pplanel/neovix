return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>tt", "<cmd>Neotest run<CR>", desc = "Run test" },
    { "<leader>ts", "<cmd>Neotest summary<CR>", desc = "Open test summary" },
  },
  opts = function()
    return {
      adapters = {
        require("rustaceanvim.neotest"),
      },
    }
  end,
}
