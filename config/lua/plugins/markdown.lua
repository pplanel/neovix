local map = vim.keymap.set

-- ── leaf: terminal markdown viewer ──────────────────────────────────────────
-- `leaf` is resolved from your PATH (it is not bundled). <Esc> in the viewer
-- closes it and drops back to editing.
---@param opts { split: boolean, watch: boolean }
local function leaf(opts)
  local file = vim.fn.expand("%:p")
  if file == "" or vim.bo.filetype ~= "markdown" then
    vim.notify("Not a valid markdown file", vim.log.levels.WARN)
    return
  end
  if vim.fn.executable("leaf") == 0 then
    vim.notify("leaf is not on PATH", vim.log.levels.ERROR)
    return
  end

  if opts.split then vim.cmd("vsplit") end

  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, term_buf)

  local cmd = { "leaf" }
  if opts.watch then table.insert(cmd, "-w") end
  table.insert(cmd, file)

  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      if vim.api.nvim_buf_is_valid(term_buf) then vim.api.nvim_buf_delete(term_buf, { force = true }) end
    end,
  })

  vim.cmd("startinsert")
  map("t", "<Esc>", "<C-\\><C-n>:bd!<CR>", { buffer = term_buf, silent = true })
end

-- stylua: ignore start
map("n", "<leader>md", function() leaf({ split = false, watch = false }) end, { desc = "Toggle Leaf Markdown Full" })
map("n", "<leader>mds", function() leaf({ split = true, watch = true }) end, { desc = "Leaf Markdown Watch Split" })
-- stylua: ignore end

-- ── render-markdown (in-buffer rendering, also for CodeCompanion chats) ────
require("render-markdown").setup({
  file_types = { "markdown", "codecompanion" },
  code = { sign = false, width = "block", right_pad = 1 },
  heading = { sign = false, icons = {} },
  checkbox = { enabled = false },
})
Snacks.toggle({
  name = "Render Markdown",
  get = function() return require("render-markdown.api").get() end,
  set = function(enabled) require("render-markdown.api").set(enabled) end,
}):map("<leader>um")

-- ── markdown-preview (browser) ──────────────────────────────────────────────
vim.g.mkdp_filetypes = { "markdown" }
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("neovix_markdown_preview", { clear = true }),
  pattern = "markdown",
  callback = function(event)
    map("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", { buffer = event.buf, desc = "Markdown Preview" })
  end,
})
