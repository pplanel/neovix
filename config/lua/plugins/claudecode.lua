local map = vim.keymap.set

-- ── claudecode.nvim: Claude Code CLI in a split, wired to Neovim over WebSocket ──
-- nix-darwin sets CLAUDE_CODE_EXECUTABLE to the personal Claude command on each
-- Mac (claude-personal on arrakis, where `claude` is the work account); falls
-- back to `claude` from PATH.
require("claudecode").setup({
  terminal_cmd = os.getenv("CLAUDE_CODE_EXECUTABLE"),
  log_level = "warn",
  terminal = { split_side = "right", split_width_percentage = 0.4 },
})

require("which-key").add({ { "<leader>a", group = "ai" } })

-- stylua: ignore start
map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Claude Code Toggle" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude Code Focus" })
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Claude Code Resume" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Claude Code Continue" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Claude Code Select Model" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Claude Code Add Buffer" })
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude Code Send Selection" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Claude Code Accept Diff" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Claude Code Deny Diff" })
-- stylua: ignore end
