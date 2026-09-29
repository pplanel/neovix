-- rustaceanvim owns rust-analyzer (don't vim.lsp.enable it). It reads this
-- global lazily when the first Rust buffer opens. bacon_ls is enabled in lsp.lua.
vim.g.rustaceanvim = {
  server = {
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
