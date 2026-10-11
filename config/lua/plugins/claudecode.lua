local map = vim.keymap.set

-- ── claudecode.nvim: Claude Code CLI in a split, wired to Neovim over WebSocket ──
-- nix-darwin sets CLAUDE_CODE_EXECUTABLE to the personal Claude command on each
-- Mac (claude-personal on arrakis, where `claude` is the work account); falls
-- back to `claude` from PATH.
local toggle_key = "<C-,>"

require("claudecode").setup({
  terminal_cmd = os.getenv("CLAUDE_CODE_EXECUTABLE"),
  log_level = "warn",
  -- Start Claude at the repo root even when nvim's cwd is a subdirectory.
  git_repo_cwd = true,
  -- Jump into the Claude split after sending a selection or file.
  focus_after_send = true,
  terminal = {
    split_side = "right",
    split_width_percentage = 0.4,
    -- Narrow the split while a diff is open so both sides stay readable.
    diff_split_width_percentage = 0.25,
    -- In terminal mode every key goes to the CLI, so the normal-mode
    -- navigator maps never fire. Only h/l: Claude uses <C-j> (newline) and
    -- <C-k> (kill line). Snacks re-enters insert mode when the window is
    -- focused again. Snacks reads a string rhs as an action name (and drops
    -- it when there's no such action), so these must be functions.
    snacks_win_opts = {
      keys = {
        claude_hide = { toggle_key, function(self) self:hide() end, mode = "t", desc = "Hide Claude" },
        nav_h = { "<C-h>", function() vim.cmd("TmuxNavigateLeft") end, mode = "t", desc = "Go to Left Window/Pane" },
        nav_l = { "<C-l>", function() vim.cmd("TmuxNavigateRight") end, mode = "t", desc = "Go to Right Window/Pane" },
        -- Normal mode for scrolling, without the first <Esc> of snacks'
        -- double-Esc reaching Claude and interrupting it.
        term_normal_q = { "<C-q>", function() vim.cmd("stopinsert") end, mode = "t", desc = "Normal Mode (scroll)" },
      },
    },
  },
})

-- Type a prompt into the running Claude session and submit it.
local function ask()
  if not require("claudecode").is_claude_connected() then
    vim.notify("Claude Code isn't running (<leader>ac to start it)", vim.log.levels.WARN)
    return
  end
  Snacks.input({ prompt = "Ask Claude" }, function(text)
    if text and text ~= "" then require("claudecode.terminal").send_to_terminal(text) end
  end)
end

require("which-key").add({ { "<leader>a", group = "ai" } })

-- stylua: ignore start
map({ "n", "x" }, toggle_key, "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude Code Focus/Hide" })
map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Claude Code Toggle" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude Code Focus" })
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Claude Code Resume" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Claude Code Continue" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Claude Code Select Model" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Claude Code Add Buffer" })
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude Code Send Selection" })
map("n", "<leader>ap", ask, { desc = "Claude Code Prompt" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Claude Code Accept Diff" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Claude Code Deny Diff" })
map("n", "<leader>aD", "<cmd>ClaudeCodeCloseAllDiffs<cr>", { desc = "Claude Code Close All Diffs" })
-- stylua: ignore end

-- <leader>as on a neo-tree node adds that file (or directory) to the context.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("neovix_claudecode_tree", { clear = true }),
  pattern = { "neo-tree", "snacks_picker_list" },
  callback = function(ev)
    map("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = ev.buf, desc = "Claude Code Add File" })
  end,
})
