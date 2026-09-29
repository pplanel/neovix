require("catppuccin").setup({
  flavour = "auto", -- mocha for dark, latte for light
  background = { light = "latte", dark = "mocha" },
  -- Listed explicitly: catppuccin's auto_integrations only detects plugins
  -- installed by vim.pack/lazy/pckr, not ones Nix puts on the packpath.
  -- (blink_cmp, dap, dap_ui, flash, gitsigns, mini, neotree and render_markdown
  -- are already on by default.)
  integrations = {
    grug_far = true,
    lsp_trouble = true,
    neotest = true,
    snacks = { enabled = true },
    which_key = true,
  },
  lsp_styles = {
    underlines = {
      errors = { "undercurl" },
      hints = { "undercurl" },
      warnings = { "undercurl" },
      information = { "undercurl" },
    },
    inlay_hints = { background = true },
  },
})

vim.cmd.colorscheme("catppuccin")
