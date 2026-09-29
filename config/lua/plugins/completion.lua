-- ── LuaSnip + friendly-snippets ─────────────────────────────────────────────
local luasnip = require("luasnip")
luasnip.config.setup({ history = true, delete_check_events = "TextChanged" })
require("luasnip.loaders.from_vscode").lazy_load()

-- ── lazydev: Neovim API types for lua_ls when editing this config ──────────
require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "snacks.nvim", words = { "Snacks" } },
  },
})

-- ── blink.cmp ───────────────────────────────────────────────────────────────
require("blink.cmp").setup({
  -- Nix ships the prebuilt Rust matcher; warn loudly if it ever goes missing.
  fuzzy = { implementation = "prefer_rust_with_warning" },
  snippets = { preset = "luasnip" },
  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    accept = { auto_brackets = { enabled = true } },
    menu = { draw = { treesitter = { "lsp" } } },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
  },
  signature = { enabled = true },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
    },
  },
  cmdline = {
    enabled = true,
    keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
    completion = { menu = { auto_show = function() return vim.fn.getcmdtype() == ":" end } },
  },
})
