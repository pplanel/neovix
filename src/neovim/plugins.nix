# Every plugin is installed into Neovim's packpath (`pack/*/start`) by
# wrapNeovimUnstable, so it is on the runtimepath at startup: no plugin
# manager, no cloning, no lockfile. Configuration lives in config/lua/plugins/.
{vimPlugins}:
with vimPlugins; {
  ui = [
    catppuccin-nvim
    lualine-nvim
    bufferline-nvim
    which-key-nvim
    neo-tree-nvim
    nui-nvim
    nvim-web-devicons
    mini-nvim
    snacks-nvim
    trouble-nvim
    todo-comments-nvim
  ];

  editing = [
    flash-nvim
    persistence-nvim
    gitsigns-nvim
    grug-far-nvim
    ts-comments-nvim
  ];

  lsp = [
    nvim-lspconfig
    conform-nvim
    nvim-lint
    lazydev-nvim
    SchemaStore-nvim
  ];

  treesitter = [
    nvim-treesitter-textobjects
    nvim-ts-autotag
  ];

  completion = [
    blink-cmp
    luasnip
    friendly-snippets
  ];

  languages = [
    rustaceanvim
    crates-nvim
    render-markdown-nvim
    markdown-preview-nvim
    venv-selector-nvim
  ];

  ai = [
    codecompanion-nvim
    plenary-nvim
    img-clip-nvim
  ];

  debug = [
    nvim-dap
    nvim-dap-ui
    nvim-dap-view
    nvim-dap-virtual-text
    nvim-dap-python
    nvim-nio
    one-small-step-for-vimkind
  ];

  testing = [
    neotest
    neotest-python
    neotest-zig
    FixCursorHold-nvim
  ];
}
