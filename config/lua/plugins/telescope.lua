-- Telescope, alongside snacks.picker: the usual <leader>f/<leader>s keys stay
-- on snacks, while Telescope lives under <leader>F to compare side by side.
local telescope = require("telescope")
local actions = require("telescope.actions")
local icons = require("config.icons").telescope

local ignore = { "^.git/", "node_modules/", "target/", "%.direnv/", "^result/", "%.build/", "DerivedData/" }

-- Jump to any result with flash labels (`s` in normal mode, <C-s> in insert).
local function flash(prompt_bufnr)
  require("flash").jump({
    pattern = "^",
    label = { after = { 0, 0 } },
    search = {
      mode = "search",
      exclude = {
        function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults" end,
      },
    },
    action = function(match)
      local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
      picker:set_selection(match.pos[1] - 1)
    end,
  })
end

local open_with_trouble = function(...) return require("trouble.sources.telescope").open(...) end

telescope.setup({
  defaults = {
    prompt_prefix = icons.prompt,
    selection_caret = icons.caret,
    multi_icon = icons.multi,
    entry_prefix = "  ",
    -- Preview beside the results on wide windows, below them on narrow ones.
    layout_strategy = "flex",
    layout_config = {
      prompt_position = "top",
      width = 0.87,
      height = 0.80,
      flex = { flip_columns = 140 },
      horizontal = { preview_width = 0.55 },
      vertical = { preview_height = 0.5, mirror = true },
    },
    sorting_strategy = "ascending",
    path_display = { "filename_first" },
    dynamic_preview_title = true,
    results_title = false,
    file_ignore_patterns = ignore,
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--glob",
      "!**/.git/*",
    },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-Down>"] = actions.cycle_history_next,
        ["<C-Up>"] = actions.cycle_history_prev,
        ["<C-t>"] = open_with_trouble,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<C-s>"] = flash,
        ["<Esc>"] = actions.close, -- one Esc closes, no normal-mode detour
      },
      n = {
        ["q"] = actions.close,
        ["s"] = flash,
        ["<C-t>"] = open_with_trouble,
      },
    },
  },
  pickers = {
    find_files = { find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" } },
    buffers = {
      sort_mru = true,
      ignore_current_buffer = true,
      mappings = { n = { ["dd"] = actions.delete_buffer } },
    },
    colorscheme = { enable_preview = true },
    help_tags = { mappings = { i = { ["<CR>"] = actions.select_vertical } } },
  },
  extensions = {
    fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" },
  },
})
telescope.load_extension("fzf") -- native sorter, prebuilt by Nix

local builtin = require("telescope.builtin")
local map = vim.keymap.set
-- stylua: ignore start
map("n", "<leader>FF", builtin.builtin, { desc = "All Pickers" })
map("n", "<leader>Ff", builtin.find_files, { desc = "Find Files" })
map("n", "<leader>Fg", builtin.live_grep, { desc = "Live Grep" })
map({ "n", "x" }, "<leader>Fw", builtin.grep_string, { desc = "Grep Word/Selection" })
map("n", "<leader>Fb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>Fr", builtin.oldfiles, { desc = "Recent Files" })
map("n", "<leader>Fh", builtin.help_tags, { desc = "Help" })
map("n", "<leader>Fk", builtin.keymaps, { desc = "Keymaps" })
map("n", "<leader>Fd", builtin.diagnostics, { desc = "Diagnostics" })
map("n", "<leader>Fs", builtin.lsp_document_symbols, { desc = "LSP Symbols" })
map("n", "<leader>FS", builtin.lsp_dynamic_workspace_symbols, { desc = "LSP Workspace Symbols" })
map("n", "<leader>Fc", builtin.git_commits, { desc = "Git Commits" })
map("n", "<leader>Fo", builtin.git_status, { desc = "Git Status" })
map("n", "<leader>F/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy Find in Buffer" })
map("n", "<leader>FC", builtin.colorscheme, { desc = "Colorschemes (live preview)" })
map("n", "<leader>F.", builtin.resume, { desc = "Resume" })
-- stylua: ignore end
