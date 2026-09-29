local map = vim.keymap.set

require("neotest").setup({
  adapters = {
    require("rustaceanvim.neotest"),
    require("neotest-python")({ dap = { justMyCode = false } }),
    require("neotest-zig"),
  },
  status = { virtual_text = true },
  output = { open_on_run = true },
  quickfix = {
    open = function() require("trouble").open({ mode = "quickfix", focus = false }) end,
  },
})

local neotest = function() return require("neotest") end

-- stylua: ignore start
map("n", "<leader>tt", "<cmd>Neotest run<CR>", { desc = "Run test" })
map("n", "<leader>ts", "<cmd>Neotest summary<CR>", { desc = "Open test summary" })
map("n", "<leader>tr", function() neotest().run.run() end, { desc = "Run Nearest" })
map("n", "<leader>tT", function() neotest().run.run(vim.fn.expand("%")) end, { desc = "Run File" })
map("n", "<leader>tA", function() neotest().run.run(vim.uv.cwd()) end, { desc = "Run All Test Files" })
map("n", "<leader>tl", function() neotest().run.run_last() end, { desc = "Run Last" })
map("n", "<leader>td", function() neotest().run.run({ strategy = "dap" }) end, { desc = "Debug Nearest" })
map("n", "<leader>to", function() neotest().output.open({ enter = true, auto_close = true }) end, { desc = "Show Output" })
map("n", "<leader>tO", function() neotest().output_panel.toggle() end, { desc = "Toggle Output Panel" })
map("n", "<leader>tS", function() neotest().run.stop() end, { desc = "Stop" })
map("n", "<leader>tw", function() neotest().watch.toggle(vim.fn.expand("%")) end, { desc = "Toggle Watch" })
-- stylua: ignore end
