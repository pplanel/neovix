# Every plugin is installed into Neovim's packpath (`pack/*/start`) by
# wrapNeovimUnstable, so it is on the runtimepath at startup: no plugin
# manager, no cloning, no lockfile. Configuration lives in config/lua/plugins/.
{
  lib,
  stdenv,
  callPackage,
  vimPlugins,
}:
with vimPlugins; {
  ui = [
    (callPackage ./pkgs/retro-82-nvim.nix {})
    onedark-nvim
    tokyonight-nvim
    catppuccin-nvim
    kanagawa-nvim
    gruvbox-nvim
    rose-pine
    nightfox-nvim
    lualine-nvim
    bufferline-nvim
    which-key-nvim
    noice-nvim
    nvim-notify
    neo-tree-nvim
    nui-nvim
    nvim-web-devicons
    mini-nvim
    snacks-nvim
    telescope-nvim
    telescope-fzf-native-nvim
    trouble-nvim
    todo-comments-nvim
    zen-mode-nvim
    image-nvim
  ];

  editing = [
    flash-nvim
    persistence-nvim
    vim-tmux-navigator
    gitsigns-nvim
    neogit
    diffview-nvim
    (callPackage ./pkgs/github-actions-nvim.nix {})
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

  # Swift's LSP comes from the system toolchain (see toolchains.nix); Xcode
  # project tooling only exists on macOS.
  swift = lib.optionals stdenv.hostPlatform.isDarwin [
    (callPackage ./pkgs/xcodebuild-nvim.nix {})
  ];

  ai = [
    codecompanion-nvim
    codecompanion-history-nvim
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
