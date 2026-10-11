-- rustaceanvim owns rust-analyzer (don't vim.lsp.enable it). It reads this
-- global lazily when the first Rust buffer opens. bacon_ls is enabled in lsp.lua.
vim.g.rustaceanvim = {
  -- Same bundled CodeLLDB as dap.lua instead of rustaceanvim's PATH/Mason lookup.
  dap = { adapter = require("config.codelldb") },
  server = {
    -- Match bacon_ls (UTF-16 only); see lsp.lua.
    capabilities = { general = { positionEncodings = { "utf-16" } } },
    on_attach = function(_, bufnr)
      -- stylua: ignore start
      -- Grouped code actions replace the plain <leader>ca in Rust buffers.
      vim.keymap.set("n", "<leader>ca", function() vim.cmd.RustLsp("codeAction") end, { buffer = bufnr, desc = "Rust Code Action" })
      vim.keymap.set("n", "<leader>dr", function() vim.cmd.RustLsp("debuggables") end, { buffer = bufnr, desc = "Rust Debuggables" })
      vim.keymap.set("n", "<leader>dR", function()
        -- Args become the binary's argv; whitespace-split, no shell quoting.
        local args = vim.split(vim.fn.input("Args: "), "%s+", { trimempty = true })
        vim.cmd.RustLsp({ "debuggables", unpack(args) })
      end, { buffer = bufnr, desc = "Rust Debuggables (args)" })
      vim.keymap.set("n", "<leader>ce", function() vim.cmd.RustLsp("explainError") end, { buffer = bufnr, desc = "Explain Error" })
      vim.keymap.set("n", "<leader>cm", function() vim.cmd.RustLsp("expandMacro") end, { buffer = bufnr, desc = "Expand Macro" })
      -- stylua: ignore end
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
          -- Isolate RA target artifacts to stop locking target/ against terminal commands
          targetDir = true,
          -- Avoid analyzing tests, benchmarks, and examples for internal indexing
          allTargets = false,
        },
        -- Scope checks to current crate and skip extra targets when checks do run
        check = {
          command = "check",
          allTargets = false,
          workspace = false,
        },
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
        -- Keep false if using bacon_ls or manual checks
        checkOnSave = false,
        diagnostics = {
          enable = true,
          experimental = { enable = false },
        },
        procMacro = { enable = true },
        -- Reduce AST traversal overhead during typing/navigation
        inlayHints = {
          lifetimeElisionHints = { enable = "never" },
          expressionAdjustmentHints = { enable = "never" },
        },
      },
    },
  },
}

-- ── crates.nvim: Cargo.toml versions, features and completion ──────────────
require("crates").setup({
  completion = { crates = { enabled = true } },
  lsp = { enabled = true, actions = true, completion = true, hover = true },
})
