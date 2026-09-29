-- vim-tmux-navigator: <C-h/j/k/l> move between Neovim splits and tmux panes
-- as one grid. Outside tmux they are plain window moves. Needs the matching
-- bindings in ~/.tmux.conf (see the plugin's README, or its TPM plugin).
--
-- The plugin's default maps use the legacy `:<C-U>` form; these replace them.
vim.g.tmux_navigator_no_mappings = 1

local map = vim.keymap.set
-- stylua: ignore start
map("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Go to Left Window/Pane" })
map("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Go to Lower Window/Pane" })
map("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Go to Upper Window/Pane" })
map("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Go to Right Window/Pane" })
map("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Go to Previous Window/Pane" })
-- stylua: ignore end
