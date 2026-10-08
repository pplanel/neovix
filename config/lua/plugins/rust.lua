-- rustaceanvim owns rust-analyzer (don't vim.lsp.enable it). It reads this
-- global lazily when the first Rust buffer opens. bacon_ls is enabled in lsp.lua.
vim.g.rustaceanvim = {
  server = {
    -- Match bacon_ls (UTF-16 only); see lsp.lua.
    capabilities = { general = { positionEncodings = { "utf-16" } } },
    on_attach = function(_, bufnr)
      -- stylua: ignore start
      -- Grouped code actions replace the plain <leader>ca in Rust buffers.
      vim.keymap.set("n", "<leader>ca", function() vim.cmd.RustLsp("codeAction") end, { buffer = bufnr, desc = "Rust Code Action" })
      vim.keymap.set("n", "<leader>dr", function() vim.cmd.RustLsp("debuggables") end, { buffer = bufnr, desc = "Rust Debuggables" })
      vim.keymap.set("n", "<leader>ce", function() vim.cmd.RustLsp("explainError") end, { buffer = bufnr, desc = "Explain Error" })
      vim.keymap.set("n", "<leader>cm", function() vim.cmd.RustLsp("expandMacro") end, { buffer = bufnr, desc = "Expand Macro" })
      -- stylua: ignore end
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true, loadOutDirsFromCheck = true, buildScripts = { enable = true } },
        files = {
          exclude = {
            ".direnv",
            ".git",
            ".jj",
            ".github",
            ".gitlab",
            "bin",
            "node_modules",
            "target",
            "venv",
            ".venv",
            "vendor",
          },
          watcher = "client",
        },
        checkOnSave = true,
        diagnostics = { enable = true },
        procMacro = { enable = true },
      },
    },
  },
}

-- ── crates.nvim: Cargo.toml versions, features and completion ──────────────
require("crates").setup({
  completion = { crates = { enabled = true } },
  lsp = { enabled = true, actions = true, completion = true, hover = true },
})

-- ── Winbar: enclosing impl/trait/mod headers via treesitter ────────────────
local container = { impl_item = true, trait_item = true, mod_item = true }

function _G.ts_winbar()
  local win = vim.g.statusline_winid
  if not win or not vim.api.nvim_win_is_valid(win) then return "" end
  local buf = vim.api.nvim_win_get_buf(win)
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  if not pcall(vim.treesitter.get_parser, buf) then return "" end

  local parts = {}
  local node = vim.treesitter.get_node({ bufnr = buf, pos = { row - 1, col } })
  while node do
    if container[node:type()] then
      local srow = node:range()
      local line = vim.api.nvim_buf_get_lines(buf, srow, srow + 1, false)[1] or ""
      table.insert(parts, 1, (vim.trim(line):gsub("%%", "%%%%")))
    end
    node = node:parent()
  end
  return table.concat(parts, "  ›  ")
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function() vim.wo.winbar = "%{%v:lua.ts_winbar()%}" end,
})
