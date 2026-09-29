{
  pkgs,
  lib ? pkgs.lib,
  ...
}: let
  jsDebugAdapter = pkgs.writeShellScriptBin "js-debug-adapter" ''
    exec ${pkgs.vscode-js-debug}/bin/js-debug "$@"
  '';

  terraformBin = pkgs.writeShellScriptBin "terraform" ''
    exec ${pkgs.opentofu}/bin/tofu "$@"
  '';

  treesitterLanguages = [
    "c"
    "lua"
    "bash"
    "json"
    "rust"
    "html"
    "yaml"
    "toml"
    "markdown"
    "nix"
    "javascript"
    "typescript"
  ];

  treesitterGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    p:
      lib.concatMap (
        lang: let
          attrName = "tree-sitter-${lang}";
          grammar = p.${attrName} or null;
        in
          if grammar != null
          then [grammar]
          else lib.warn "treesitter grammar for '${lang}' not found" []
      )
      treesitterLanguages
  );

  extraPackages = with pkgs; [
    # Lua toolchain
    lua5_1
    luarocks
    lua-language-server

    # Nix toolchain
    nil
    nixd
    alejandra
    statix

    # Rust toolchain
    rust-analyzer
    bacon
    lldb

    # Go toolchain
    gopls
    delve
    gofumpt
    gotools
    golangci-lint
    gomodifytags
    gotests
    iferr
    impl

    # Python toolchain
    pyright
    ruff
    python3Packages.debugpy

    # Web, TypeScript, Tailwind, JSON, YAML
    vtsls
    tailwindcss-language-server
    vscode-langservers-extracted
    yaml-language-server
    vscode-js-debug

    # Shell & Infrastructure
    bash-language-server
    shellcheck
    shfmt
    terraform-ls
    tflint

    # Markdown, Docs, TOML, Lua formatters
    marksman
    markdown-toc
    markdownlint-cli2
    taplo
    stylua

    # Zig & Swift
    zls
    swiftformat

    # Runtime utilities for AI & MCP (Node, Curl, Git)
    nodejs_22
    curl
    git

    # DAP Adapters
    jsDebugAdapter

    # System & Clipboard Utilities
    pngpaste
    ast-grep

    # Formatters (conform.nvim)
    prettier
    terraformBin
    opentofu
    fish
    packer

    # Terminal Image Viewers & Media Previewers (fzf-lua, snacks)
    chafa
    viu
    ueberzugpp
    imagemagick
    ghostscript
    tectonic
    mermaid-cli
  ];

  vp = pkgs.vimPlugins;

  lazyPlugins = pkgs.linkFarm "lazy-plugins" [
    {
      name = "FixCursorHold.nvim";
      path = vp.FixCursorHold-nvim;
    }
    {
      name = "LazyVim";
      path = vp.LazyVim;
    }
    {
      name = "LuaSnip";
      path = vp.luasnip;
    }
    {
      name = "SchemaStore.nvim";
      path = vp.SchemaStore-nvim;
    }
    {
      name = "blink.cmp";
      path = vp.blink-cmp;
    }
    {
      name = "bufferline.nvim";
      path = vp.bufferline-nvim;
    }
    {
      name = "catppuccin";
      path = vp.catppuccin-nvim;
    }
    {
      name = "codecompanion.nvim";
      path = vp.codecompanion-nvim;
    }
    {
      name = "conform.nvim";
      path = vp.conform-nvim;
    }
    {
      name = "crates.nvim";
      path = vp.crates-nvim;
    }
    {
      name = "flash.nvim";
      path = vp.flash-nvim;
    }
    {
      name = "friendly-snippets";
      path = vp.friendly-snippets;
    }
    {
      name = "fzf-lua";
      path = vp.fzf-lua;
    }
    {
      name = "gh.nvim";
      path = vp.gh-nvim;
    }
    {
      name = "gitsigns.nvim";
      path = vp.gitsigns-nvim;
    }
    {
      name = "grug-far.nvim";
      path = vp.grug-far-nvim;
    }
    {
      name = "img-clip.nvim";
      path = vp.img-clip-nvim;
    }
    {
      name = "lazy.nvim";
      path = vp.lazy-nvim;
    }
    {
      name = "lazydev.nvim";
      path = vp.lazydev-nvim;
    }
    {
      name = "litee.nvim";
      path = vp.litee-nvim;
    }
    {
      name = "lualine.nvim";
      path = vp.lualine-nvim;
    }
    {
      name = "markdown-preview.nvim";
      path = vp.markdown-preview-nvim;
    }
    {
      name = "mini.ai";
      path = vp.mini-nvim;
    }
    {
      name = "mini.icons";
      path = vp.mini-nvim;
    }
    {
      name = "mini.nvim";
      path = vp.mini-nvim;
    }
    {
      name = "mini.pairs";
      path = vp.mini-nvim;
    }
    {
      name = "mini.surround";
      path = vp.mini-nvim;
    }
    {
      name = "neo-tree.nvim";
      path = vp.neo-tree-nvim;
    }
    {
      name = "neotest";
      path = vp.neotest;
    }
    {
      name = "neotest-python";
      path = vp.neotest-python;
    }
    {
      name = "neotest-zig";
      path = vp.neotest-zig;
    }
    {
      name = "noice.nvim";
      path = vp.noice-nvim;
    }
    {
      name = "nui.nvim";
      path = vp.nui-nvim;
    }
    {
      name = "nvim-dap";
      path = vp.nvim-dap;
    }
    {
      name = "nvim-dap-python";
      path = vp.nvim-dap-python;
    }
    {
      name = "nvim-dap-ui";
      path = vp.nvim-dap-ui;
    }
    {
      name = "nvim-dap-view";
      path = vp.nvim-dap-view;
    }
    {
      name = "nvim-dap-virtual-text";
      path = vp.nvim-dap-virtual-text;
    }
    {
      name = "nvim-lint";
      path = vp.nvim-lint;
    }
    {
      name = "nvim-lspconfig";
      path = vp.nvim-lspconfig;
    }
    {
      name = "nvim-nio";
      path = vp.nvim-nio;
    }
    {
      name = "nvim-treesitter";
      path = vp.nvim-treesitter.withAllGrammars;
    }
    {
      name = "nvim-treesitter-textobjects";
      path = vp.nvim-treesitter-textobjects;
    }
    {
      name = "nvim-ts-autotag";
      path = vp.nvim-ts-autotag;
    }
    {
      name = "nvim-web-devicons";
      path = vp.nvim-web-devicons;
    }
    {
      name = "one-small-step-for-vimkind";
      path = vp.one-small-step-for-vimkind;
    }
    {
      name = "persistence.nvim";
      path = vp.persistence-nvim;
    }
    {
      name = "plenary.nvim";
      path = vp.plenary-nvim;
    }
    {
      name = "render-markdown.nvim";
      path = vp.render-markdown-nvim;
    }
    {
      name = "rustaceanvim";
      path = vp.rustaceanvim;
    }
    {
      name = "snacks.nvim";
      path = vp.snacks-nvim;
    }
    {
      name = "todo-comments.nvim";
      path = vp.todo-comments-nvim;
    }
    {
      name = "tokyonight.nvim";
      path = vp.tokyonight-nvim;
    }
    {
      name = "trouble.nvim";
      path = vp.trouble-nvim;
    }
    {
      name = "ts-comments.nvim";
      path = vp.ts-comments-nvim;
    }
    {
      name = "venv-selector.nvim";
      path = vp.venv-selector-nvim;
    }
    {
      name = "vim-tmux-navigator";
      path = vp.vim-tmux-navigator;
    }
    {
      name = "which-key.nvim";
      path = vp.which-key-nvim;
    }
  ];

  configDir = ./config;

  luaInit = ''
    local config_dir = "${configDir}"
    local lazy_plugins = "${lazyPlugins}"

    vim.env.LAZY_PLUGINS = lazy_plugins
    vim.env.NEOVIM_CONFIG = config_dir
    vim.g.lazyvim_json = config_dir .. "/lazyvim.json"
    package.path = config_dir .. "/lua/?.lua;" .. config_dir .. "/lua/?/init.lua;" .. package.path
    local user_config = vim.fn.expand("~/.config/nvim")
    vim.opt.runtimepath:remove(user_config)
    vim.opt.runtimepath:remove(user_config .. "/after")

    vim.opt.runtimepath:prepend(config_dir)
    vim.opt.runtimepath:append(config_dir .. "/after")
    vim.opt.runtimepath:prepend(lazy_plugins .. "/lazy.nvim")

    dofile(config_dir .. "/init.lua")
  '';
in
  pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    luaRcContent = luaInit;
    extraLuaPackages = ps: [ps.jsregexp];
    plugins = [treesitterGrammars lazyPlugins];
    wrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath extraPackages)
    ];
  }
