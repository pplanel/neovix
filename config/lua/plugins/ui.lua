local map = vim.keymap.set
local icons = require("config.icons")

-- ── snacks.nvim ─────────────────────────────────────────────────────────────
-- Snacks' built-in "startup" section and session detection assume lazy.nvim,
-- so the dashboard footer and session key are provided here instead.
local function startup_footer()
  local plugins = #vim.fn.globpath(vim.o.packpath, "pack/*/start/*", false, true)
  local ms = vim.g.neovix_startuptime or (vim.uv.hrtime() - vim.g.neovix_start) / 1e6
  return {
    align = "center",
    text = {
      { icons.ui.bolt .. " neovix ", hl = "footer" },
      { "· " .. plugins .. " plugins from Nix · ", hl = "footer" },
      { ("%.1fms"):format(ms), hl = "special" },
    },
  }
end

require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true, timeout = 3000 },
  indent = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = false },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  picker = { enabled = true, ui_select = true },
  -- render-markdown renders LaTeX math (as Unicode); two renderers conflict.
  image = { enabled = true, math = { enabled = false } },
  dashboard = {
    enabled = true,
    preset = {
      -- stylua: ignore
      keys = {
        { icon = icons.dashboard.find, key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
        { icon = icons.dashboard.new, key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = icons.dashboard.grep, key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
        { icon = icons.dashboard.recent, key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
        { icon = icons.dashboard.config, key = "c", desc = "Config", action = ":lua Snacks.picker.files({ cwd = vim.g.neovix.config })" },
        { icon = icons.dashboard.session, key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
        { icon = icons.dashboard.quit, key = "q", desc = "Quit", action = ":qa" },
      },
      header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗██╗  ██╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║╚██╗██╔╝
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║ ╚███╔╝ 
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║ ██╔██╗ 
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██╔╝ ██╗
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝  ╚═╝]],
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      startup_footer,
    },
  },
})

-- Pickers
-- stylua: ignore start
map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
map("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "Command History" })
map("n", "<leader>n", function() Snacks.picker.notifications() end, { desc = "Notification History" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.g.neovix.config }) end, { desc = "Find Config File" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
map("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find Git Files" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent" })
map("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
map("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })
map("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
map("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
map("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
map("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
map({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Visual selection or word" })
map("n", "<leader>s\"", function() Snacks.picker.registers() end, { desc = "Registers" })
map("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
map("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command History" })
map("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
map("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
map("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
map("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages" })
map("n", "<leader>sH", function() Snacks.picker.highlights() end, { desc = "Highlights" })
map("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons" })
map("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
map("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List" })
map("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
map("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
map("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
map("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume" })
map("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "Undo History" })
map("n", "<leader>uC", function() Snacks.picker.colorschemes() end, { desc = "Colorschemes" })
map("n", "<leader>un", function() Snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })
map("n", "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
map({ "n", "t" }, "]]", function() Snacks.words.jump(vim.v.count1) end, { desc = "Next Reference" })
map({ "n", "t" }, "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })
-- stylua: ignore end

-- ── noice: cmdline, messages and LSP docs UI ────────────────────────────────
-- Notifications still go through Snacks.notifier (noice's notify view prefers
-- the snacks backend).
require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
    -- blink.cmp already shows signature help; two would stack.
    signature = { enabled = false },
  },
  routes = {
    -- Undo/redo and write messages go to the small corner view.
    {
      filter = {
        event = "msg_show",
        any = { { find = "%d+L, %d+B" }, { find = "; after #%d+" }, { find = "; before #%d+" } },
      },
      view = "mini",
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
  },
})

-- stylua: ignore start
map("c", "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, { desc = "Redirect Cmdline" })
map("n", "<leader>snl", function() require("noice").cmd("last") end, { desc = "Noice Last Message" })
map("n", "<leader>snh", function() require("noice").cmd("history") end, { desc = "Noice History" })
map("n", "<leader>sna", function() require("noice").cmd("all") end, { desc = "Noice All" })
map("n", "<leader>snd", function() require("noice").cmd("dismiss") end, { desc = "Dismiss All" })
map("n", "<leader>snt", function() require("noice").cmd("pick") end, { desc = "Noice Picker" })
map({ "i", "n", "s" }, "<c-f>", function()
  if not require("noice.lsp").scroll(4) then return "<c-f>" end
end, { silent = true, expr = true, desc = "Scroll Forward" })
map({ "i", "n", "s" }, "<c-b>", function()
  if not require("noice.lsp").scroll(-4) then return "<c-b>" end
end, { silent = true, expr = true, desc = "Scroll Backward" })
-- stylua: ignore end

-- ── which-key ───────────────────────────────────────────────────────────────
require("which-key").setup({
  preset = "helix",
  spec = {
    {
      mode = { "n", "v" },
      { "<leader><tab>", group = "tabs" },
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "debug" },
      { "<leader>f", group = "file/find" },
      { "<leader>F", group = "telescope" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>m", group = "markdown" },
      { "<leader>q", group = "quit/session" },
      { "<leader>s", group = "search" },
      { "<leader>sn", group = "noice" },
      { "<leader>t", group = "test" },
      { "<leader>u", group = "ui" },
      { "<leader>w", group = "windows", proxy = "<c-w>" },
      { "<leader>x", group = "diagnostics/quickfix" },
      { "<leader>X", group = "swift/xcode" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "gs", group = "surround" },
      { "z", group = "fold" },
    },
  },
})
map("n", "<leader>?", function() require("which-key").show({ global = false }) end, { desc = "Buffer Keymaps" })

-- ── lualine ─────────────────────────────────────────────────────────────────
local signs = vim.diagnostic.config().signs.text

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    component_separators = "",
    section_separators = { left = icons.ui.sep_right, right = icons.ui.sep_left },
    disabled_filetypes = { statusline = { "snacks_dashboard" } },
  },
  sections = {
    lualine_a = { { "mode", separator = { left = icons.ui.sep_left }, right_padding = 2 } },
    lualine_b = { "branch", "diff" },
    lualine_c = {
      {
        "diagnostics",
        symbols = {
          error = signs[vim.diagnostic.severity.ERROR],
          warn = signs[vim.diagnostic.severity.WARN],
          info = signs[vim.diagnostic.severity.INFO],
          hint = signs[vim.diagnostic.severity.HINT],
        },
      },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { "filename", path = 1, symbols = { modified = " ●", readonly = " " .. icons.ui.lock, unnamed = "" } },
    },
    lualine_x = {
      {
        function()
          local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
          return #names > 0 and (icons.ui.gear .. " " .. table.concat(names, " ")) or ""
        end,
        color = "Comment",
      },
      Snacks.profiler.status(),
    },
    lualine_y = { "progress" },
    lualine_z = { { "location", separator = { right = icons.ui.sep_right }, left_padding = 2 } },
  },
  extensions = { "neo-tree", "trouble", "quickfix", "nvim-dap-ui" },
})

-- ── bufferline ──────────────────────────────────────────────────────────────
require("bufferline").setup({
  options = {
    close_command = function(n) Snacks.bufdelete(n) end,
    right_mouse_command = function(n) Snacks.bufdelete(n) end,
    diagnostics = "nvim_lsp",
    always_show_bufferline = false,
    diagnostics_indicator = function(_, _, diag)
      local ret = (diag.error and signs[vim.diagnostic.severity.ERROR] .. diag.error .. " " or "")
        .. (diag.warning and signs[vim.diagnostic.severity.WARN] .. diag.warning or "")
      return vim.trim(ret)
    end,
    offsets = {
      { filetype = "neo-tree", text = "Explorer", highlight = "Directory", text_align = "left" },
    },
  },
})
-- stylua: ignore start
map("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle Pin" })
map("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })
map("n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Delete Buffers to the Right" })
map("n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Delete Buffers to the Left" })
map("n", "[B", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer prev" })
map("n", "]B", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer next" })
-- stylua: ignore end

-- ── trouble & todo-comments ─────────────────────────────────────────────────
require("trouble").setup({ modes = { lsp = { win = { position = "right" } } } })
require("todo-comments").setup()

-- stylua: ignore start
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols (Trouble)" })
map("n", "<leader>cS", "<cmd>Trouble lsp toggle<cr>", { desc = "LSP references/definitions/... (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
map("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo Comment" })
map("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous Todo Comment" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo (Trouble)" })
map("n", "<leader>st", function() Snacks.picker.todo_comments() end, { desc = "Todo" })
-- stylua: ignore end
