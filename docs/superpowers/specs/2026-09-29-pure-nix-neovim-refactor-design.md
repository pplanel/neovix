# Design Spec: Pure Nix-Managed Neovim Refactor

## 1. Overview & Goals

This project refactors `neovix` from a hybrid LazyVim/lazy.nvim wrapper into a clean, pure Nix-managed Neovim distribution.

### Core Problems Solved
1. **Elimination of lazy.nvim link-farm hacks**:
   - Previously, 59 plugins were manually mapped in a 230-line `pkgs.linkFarm` in `default.nix` and exposed via `lazy_opts.dev.path` to fake local plugin development.
   - Replaced by native Neovim package loading via Nixpkgs `pkgs.wrapNeovimUnstable` with plugins placed directly into Neovim's `packpath`. Neovim loads them immediately and deterministically without cloning or mutating files.
2. **Elimination of Mason conflict workarounds**:
   - `disabled.lua` was used to sever dependencies from `nvim-lspconfig` and disable `mason.nvim` and `mason-lspconfig.nvim`.
   - With pure Lua configuration and direct `vim.lsp.config` / `setup` calls, Mason is entirely removed with no residual shims.
3. **Treesitter Grammar Deduplication**:
   - Previous configuration both compiled a custom grammar set via `nvim-treesitter.withPlugins` and injected `withAllGrammars` into the link farm, passing both to `wrapNeovimUnstable`.
   - Replaced by a single clean `treesitter.nix` module using `nvim-treesitter.withAllGrammars` (or curated grammars).
4. **Thin Flake Public Surface & Modular Implementation**:
   - Follows `nix-flake-organization` and `nix-best-practices`.
   - `flake.nix` is a thin entrypoint delegating to `flake/`.
   - Implementation logic lives under `src/neovim/` with modular files (`package.nix`, `plugins.nix`, `toolchains.nix`, `treesitter.nix`).
5. **Preservation of User Workflows**:
   - Retains Gemini 3.8 Flash + MCP + custom skills/rules in `codecompanion.nvim`.
   - Retains custom `leaf` markdown runner (`<leader>md`, `<leader>mds`).
   - Retains `rustaceanvim` + `bacon_ls`.
   - Retains `conform.nvim` with `alejandra`, `shfmt`, and dynamic `nixd` darwin/home-manager evaluation.
   - Retains `neotest`, `nvim-dap`, `nvim-dap-view`, `catppuccin`, `neo-tree`, `blink.cmp`, etc.

---

## 2. Nix Architecture

### File Layout
```text
flake.nix                         # Minimal flake entrypoint
flake/
  default.nix                     # Top-level flake output aggregator
  packages/default.nix            # packages.${system}.{default, neovim}
  apps/default.nix                # apps.${system}.default
  devShells/default.nix           # devShells.${system}.default
  overlays/default.nix            # overlays.default
src/
  neovim/
    package.nix                   # wrapNeovimUnstable derivation
    plugins.nix                   # Declarative list of plugins from pkgs.vimPlugins
    toolchains.nix                # Categorized extraPackages (Rust, Nix, Go, Python, AI, etc.)
    treesitter.nix                # Treesitter grammars derivation
```

### Module Responsibilities

1. **`flake.nix`**:
   - Inputs: `nixpkgs` (nixpkgs-unstable), `flake-utils`.
   - Outputs: Imports `./flake` passing inputs.

2. **`flake/`**:
   - `packages/default.nix`: Calls `src/neovim/package.nix` for each default system.
   - `apps/default.nix`: Wraps package's `bin/nvim`.
   - `devShells/default.nix`: Provides `mkShell` with Neovim package.
   - `overlays/default.nix`: Exposes `neovim = final.callPackage ../../src/neovim/package.nix { };`.

3. **`src/neovim/toolchains.nix`**:
   - Categorized sets of CLI tools exposed on PATH:
     - `nix`: nil, nixd, alejandra, statix
     - `rust`: rust-analyzer, bacon, lldb
     - `go`: gopls, delve, gofumpt, gotools, golangci-lint, gomodifytags, gotests, iferr, impl
     - `python`: pyright, ruff, python3Packages.debugpy
     - `web`: vtsls, tailwindcss-language-server, vscode-langservers-extracted, yaml-language-server, vscode-js-debug
     - `shell`: bash-language-server, shellcheck, shfmt, terraform-ls, tflint, opentofu
     - `docs`: marksman, markdown-toc, markdownlint-cli2, taplo, stylua
     - `ai`: nodejs_22, curl, git, ast-grep, pngpaste
     - `media`: chafa, viu, ueberzugpp, imagemagick, ghostscript, tectonic, mermaid-cli
     - `wrappers`: js-debug-adapter, terraform (alias to opentofu)

4. **`src/neovim/plugins.nix`**:
   - Clean list of Vim plugins from `pkgs.vimPlugins`:
     - UI: `catppuccin-nvim`, `lualine-nvim`, `bufferline-nvim`, `which-key-nvim`, `neo-tree-nvim`, `nui-nvim`, `nvim-web-devicons`, `mini-nvim`, `snacks-nvim`, `fzf-lua`, `trouble-nvim`, `todo-comments-nvim`
     - LSP & Editing: `nvim-lspconfig`, `conform-nvim`, `crates-nvim`, `gitsigns-nvim`, `grug-far-nvim`, `ts-comments-nvim`
     - Treesitter: `nvim-treesitter-textobjects`, `nvim-ts-autotag`
     - Completion: `blink-cmp`, `luasnip`, `friendly-snippets`
     - Languages: `rustaceanvim`, `render-markdown-nvim`, `markdown-preview-nvim`, `venv-selector-nvim`
     - AI: `codecompanion-nvim`, `plenary-nvim`, `img-clip-nvim`
     - DAP & Testing: `nvim-dap`, `nvim-dap-ui`, `nvim-dap-view`, `nvim-dap-virtual-text`, `nvim-nio`, `neotest`, `neotest-python`, `neotest-zig`, `FixCursorHold-nvim`, `one-small-step-for-vimkind`

5. **`src/neovim/package.nix`**:
   - Calls `wrapNeovimUnstable` with:
     - `plugins = pluginsList ++ [ treesitterGrammars ]`
     - `extraPackages = toolchainsList`
     - `luaRcContent`: Simple bootstrap ensuring runtimepath includes `./config` and executing `require('init')` or `dofile(...)`.

---

## 3. Neovim Lua Configuration

### File Layout
```text
config/
  init.lua                        # Global options, leader keys, loads config modules
  lua/
    config/
      options.lua                 # Core Neovim options
      keymaps.lua                 # Core keymaps
      autocmds.lua                # Standard autocommands
    plugins/
      theme.lua                   # Catppuccin theme configuration
      ui.lua                      # Lualine, bufferline, which-key, snacks, trouble
      tree.lua                    # Neo-tree configuration
      treesitter.lua              # nvim-treesitter configuration
      lsp.lua                     # nvim-lspconfig (nixd, bashls, pyright, gopls, vtsls)
      rust.lua                    # rustaceanvim & bacon_ls
      completion.lua              # blink.cmp & luasnip
      format.lua                  # conform.nvim
      ai.lua                      # codecompanion.nvim (Gemini 3.8 Flash, MCP, rules)
      markdown.lua                # leaf terminal runner & render-markdown
      dap.lua                     # nvim-dap & dap-view
      testing.lua                 # neotest
```

### Removed Artifacts
- `config/lazy-lock.json`
- `config/lazyvim.json`
- `config/lua/config/lazy.lua`
- `config/lua/plugins/disabled.lua`
- `.repro/`

---

## 4. Verification & Testing

1. `nix flake check` — Verify all outputs eval across platforms without error.
2. `nix build .#neovim` — Build the wrapped Neovim derivation.
3. Headless execution verification:
   - `./result/bin/nvim --headless -c "checkhealth" -c "q"`
   - Test plugin loading: ensure `catppuccin`, `codecompanion`, `conform`, `lspconfig`, `rustaceanvim`, `blink.cmp` load without Lua errors.

---

## 5. Implementation Notes (2026-09-29)

Where the implementation differs from the design above, and why:

- **Additional layout**: `flake/checks/` (headless smoke test, implemented in
  `src/neovim/checks/`), `src/neovim/devshell.nix`, `src/neovim/pkgs/bacon-ls.nix`,
  `config/lua/config/icons.lua`, and `config/lua/plugins/editor.lua` (mini, flash,
  persistence, gitsigns, grug-far). Implementation stays out of `flake/`, per
  `nix-flake-organization`.
- **bacon-ls packaged**: it is not in nixpkgs, so the `bacon_ls` setup never had
  a binary. It is now built from crates.io (0.31.0).
- **Runtimes appended to PATH**: `go` (needed by gopls, which previously errored
  on every `.go` file), `nodejs_22`, `git` and `curl` go in a `runtimes`
  category that is suffixed rather than prefixed, so project toolchains are never
  shadowed. debugpy's interpreter is passed by store path instead of being put on
  PATH.
- **Plugins**: added `flash`, `persistence`, `nvim-lint`, `lazydev`,
  `SchemaStore`, `nvim-dap-python` (LazyVim behaviours in daily use). Dropped
  `fzf-lua` in favour of `snacks.picker`, and dropped LazyVim, lazy.nvim,
  tokyonight, noice, gh.nvim, litee and vim-tmux-navigator.
- **Treesitter**: nixpkgs ships the nvim-treesitter `main` rewrite, so there is no
  `configs.setup`. Highlight, folds and indent are enabled per buffer from a
  FileType autocmd.
- **Staged loading**: completion, AI, DAP and testing load on `UIEnter`. The
  eager config takes about 45 ms, down from about 130 ms when everything loaded
  eagerly.
- **Unfree**: only `packer` is allowed (`allowUnfreePredicate`), replacing the
  global `allowUnfree = true`.
- **Systems**: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`. nixpkgs 26.11
  dropped `x86_64-darwin`, and the old `pngpaste` dependency broke Linux
  evaluation; it is now darwin-only.
- **nixd**: the flake is resolved per LSP root with valid attribute quoting (the
  old `.'hostname'` was not valid Nix) and falls back to `<nixpkgs>` outside
  flakes.
- **Removed**: `config/.neoconf.json` and `config/README.md` (LazyVim starter),
  plus the artifacts listed in §3. `.repro/` is untracked (gitignored) scratch
  state and was left on disk.
