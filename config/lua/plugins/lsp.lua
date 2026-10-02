-- Native LSP (vim.lsp.config / vim.lsp.enable). nvim-lspconfig contributes only
-- the per-server defaults under its lsp/ directory; every binary comes from
-- the Nix toolchains on PATH. Rust is owned by rustaceanvim (see rust.lua).
-- Completion capabilities are registered by blink.cmp's own plugin/ script.

-- Offer only UTF-16 so every client on a buffer agrees: pyright and bacon_ls
-- can't do UTF-8, and ruff would otherwise pick it (mixed encodings garble
-- edits). rust-analyzer gets the same setting in rust.lua.
local utf16 = { general = { positionEncodings = { "utf-16" } } }
vim.lsp.config("*", { capabilities = utf16 })

-- ── Nix ─────────────────────────────────────────────────────────────────────
vim.lsp.config("nil_ls", {
  settings = { ["nil"] = { formatting = { command = { "alejandra" } } } },
})

-- ── Lua ─────────────────────────────────────────────────────────────────────
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "Snacks" } },
      workspace = { checkThirdParty = false },
      completion = { callSnippet = "Replace" },
      hint = { enable = true, setType = false, paramType = true, arrayIndex = "Disable" },
      doc = { privateName = { "^_" } },
    },
  },
})

-- ── Go ──────────────────────────────────────────────────────────────────────
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      semanticTokens = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      analyses = { nilness = true, unusedparams = true, unusedwrite = true, useany = true },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- ── Python: pyright for types, ruff for lint/fixes ─────────────────────────
vim.lsp.config("ruff", {
  on_attach = function(client) client.server_capabilities.hoverProvider = false end,
})

require("venv-selector").setup({ options = { notify_user_on_venv_activation = true } })
vim.keymap.set("n", "<leader>cv", "<cmd>VenvSelect<cr>", { desc = "Select VirtualEnv" })

-- ── TypeScript / JavaScript ─────────────────────────────────────────────────
local ts_settings = {
  updateImportsOnFileMove = { enabled = "always" },
  suggest = { completeFunctionCalls = true },
  inlayHints = {
    enumMemberValues = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = "literals" },
    parameterTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = false },
  },
}
vim.lsp.config("vtsls", {
  settings = {
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = { completion = { enableServerSideFuzzyMatch = true } },
    },
    typescript = ts_settings,
    javascript = ts_settings,
  },
})

-- Tailwind's upstream root falls back to any .git dir, so without this it
-- attaches to every Markdown file in every repository.
vim.lsp.config("tailwindcss", {
  filetypes = vim.tbl_filter(
    function(ft) return ft ~= "markdown" and ft ~= "mdx" end,
    vim.lsp.config.tailwindcss.filetypes or {}
  ),
})

-- ── JSON / YAML with SchemaStore catalogs ───────────────────────────────────
-- The catalogs are large; they're loaded when a server starts, not at startup.
vim.lsp.config("jsonls", {
  settings = { json = { validate = { enable = true }, format = { enable = true } } },
  before_init = function(_, config) config.settings.json.schemas = require("schemastore").json.schemas() end,
})

vim.lsp.config("yamlls", {
  -- Upstream also lists compound filetypes (yaml.gitlab, …) nothing here sets.
  filetypes = { "yaml" },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      format = { enable = true },
      validate = true,
      -- Disable the built-in store so SchemaStore.nvim is the only catalog.
      schemaStore = { enable = false, url = "" },
    },
  },
  before_init = function(_, config) config.settings.yaml.schemas = require("schemastore").yaml.schemas() end,
})

-- ── Rust: bacon diagnostics alongside rustaceanvim's rust-analyzer ─────────
vim.lsp.config("bacon_ls", {
  init_options = { updateOnSave = true },
})

vim.lsp.enable({
  "nil_ls",
  "lua_ls",
  "bashls",
  "pyright",
  "ruff",
  "gopls",
  "vtsls",
  "tailwindcss",
  "jsonls",
  "yamlls",
  "html",
  "cssls",
  "marksman",
  "taplo",
  "terraformls",
  "tflint",
  "zls",
  "bacon_ls",
})

-- ── Buffer-local keymaps on attach ──────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("neovix_lsp_attach", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc, nowait = true })
    end

    -- stylua: ignore start
    map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
    map("n", "gr", function() Snacks.picker.lsp_references() end, "References")
    map("n", "gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation")
    map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, "Goto T[y]pe Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("n", "K", function() vim.lsp.buf.hover() end, "Hover")
    map("n", "gK", function() vim.lsp.buf.signature_help() end, "Signature Help")
    map("i", "<c-k>", function() vim.lsp.buf.signature_help() end, "Signature Help")
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>cR", function() Snacks.rename.rename_file() end, "Rename File")
    map("n", "<leader>cl", function() Snacks.picker.lsp_config() end, "Lsp Info")
    map("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, "LSP Symbols")
    map("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, "LSP Workspace Symbols")
    -- stylua: ignore end

    if client:supports_method("textDocument/inlayHint") then vim.lsp.inlay_hint.enable(true, { bufnr = event.buf }) end
    if client:supports_method("textDocument/foldingRange") then vim.wo[0][0].foldexpr = "v:lua.vim.lsp.foldexpr()" end
  end,
})
