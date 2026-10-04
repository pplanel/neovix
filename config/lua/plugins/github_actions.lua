local map = vim.keymap.set
local actions = require("github-actions")

actions.setup()

map("n", "<leader>gad", actions.dispatch_workflow, { desc = "Dispatch Workflow" })
map("n", "<leader>gah", actions.show_history, { desc = "Workflow History" })
map("n", "<leader>gap", function() actions.show_history({ pr_mode = true }) end, { desc = "Workflow History by PR" })
map("n", "<leader>gaw", actions.watch_workflow, { desc = "Watch Running Workflow" })
map("n", "<leader>gao", actions.open_workflow_url, { desc = "Open Workflow URL" })
