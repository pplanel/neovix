-- ── conform.nvim ────────────────────────────────────────────────────────────
-- Format on save unless disabled globally (vim.g.autoformat) or per buffer
-- (vim.b.autoformat). Filetypes not listed fall back to the LSP formatter.
local web = { "prettier" }

require("conform").setup({
  default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
  formatters_by_ft = {
    nix = { "alejandra" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    fish = { "fish_indent" },
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    go = { "goimports", "gofumpt" },
    toml = { "taplo" },
    terraform = { "terraform_fmt" },
    tf = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
    hcl = { "packer_fmt" },
    -- swift: chosen per project in swift.lua
    javascript = web,
    javascriptreact = web,
    typescript = web,
    typescriptreact = web,
    vue = web,
    css = web,
    scss = web,
    html = web,
    json = web,
    jsonc = web,
    yaml = web,
    graphql = web,
    markdown = { "prettier", "markdown-toc" },
    ["markdown.mdx"] = { "prettier", "markdown-toc" },
  },
  formatters = {
    -- Only regenerate a TOC when the document asks for one.
    ["markdown-toc"] = {
      condition = function(_, ctx)
        for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
          if line:find("<!%-%- toc %-%->") then return true end
        end
      end,
    },
  },
  format_on_save = function(buf)
    local enabled = vim.b[buf].autoformat
    if enabled == nil then enabled = vim.g.autoformat end
    if enabled then return {} end
  end,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set({ "n", "x" }, "<leader>cf", function() require("conform").format() end, { desc = "Format" })

Snacks.toggle({
  name = "Auto Format (Global)",
  get = function() return vim.g.autoformat end,
  set = function(state)
    vim.g.autoformat = state
    vim.b.autoformat = nil
  end,
}):map("<leader>uf")

Snacks.toggle({
  name = "Auto Format (Buffer)",
  get = function()
    if vim.b.autoformat == nil then return vim.g.autoformat end
    return vim.b.autoformat
  end,
  set = function(state) vim.b.autoformat = state end,
}):map("<leader>uF")

-- ── nvim-lint (linters that aren't language servers) ────────────────────────
local lint = require("lint")
lint.linters_by_ft = {
  markdown = { "markdownlint-cli2" },
  nix = { "statix" },
  go = { "golangcilint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("neovix_lint", { clear = true }),
  callback = function() lint.try_lint() end,
})
