<p align="center">
  <img src="docs/assets/logo.png" alt="neovix logo" width="160">
</p>

<h1 align="center">neovix</h1>

<p align="center">
  <em>Neovim, fully built by Nix: plugins, parsers and toolchains included.</em>
</p>

---

A pure, Nix-managed Neovim distribution. Every plugin, treesitter parser,
language server, formatter, linter and debug adapter comes from the Nix store:
no plugin manager, no Mason, no runtime downloads, no lockfile other than
`flake.lock`.

```bash
nix run github:pplanel/neovix    # try it
nix run .                        # from a checkout
```

- **Native packages**: plugins are installed into Neovim's `packpath` by
  `wrapNeovimUnstable` and are on the runtimepath at startup. Configuration is
  plain Lua calling `setup()`.
- **Native LSP**: servers are configured with `vim.lsp.config` /
  `vim.lsp.enable` (Neovim 0.12). nvim-lspconfig only supplies defaults.
- **Fast**: about 45 ms of config runs before the first frame. Completion,
  AI, debugging and testing load right after the UI appears.
- **Tested**: `nix flake check` boots the real package headlessly and fails on
  any startup error, missing binary, broken parser or file-open failure.

---

## Layout

```text
flake.nix                    # inputs + `outputs = import ./flake`
flake/                       # public outputs only (thin wiring)
  default.nix                #   per-system aggregation, supported systems
  packages/ apps/ devShells/ checks/ overlays/
src/neovim/                  # implementation
  package.nix                #   wrapNeovimUnstable + bootstrap
  plugins.nix                #   plugins, grouped by domain
  toolchains.nix             #   CLI tools on PATH, grouped by domain
  treesitter.nix             #   all grammars, prebuilt
  pkgs/bacon-ls.nix          #   packages missing from nixpkgs
  devshell.nix
  checks/smoke.{nix,lua}     #   headless boot test
config/                      # the Neovim config (Lua)
  init.lua                   #   staged loader
  lua/config/                #   options, keymaps, autocmds, icons
  lua/plugins/               #   one file per area, see below
```

| `config/lua/plugins/` | What it sets up                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------------- |
| `theme.lua`           | catppuccin (mocha / latte follows `background`)                                                         |
| `ui.lua`              | snacks (dashboard, picker, notifier, terminal…), which-key, lualine, bufferline, trouble, todo-comments |
| `editor.lua`          | mini.ai / surround / pairs, flash, persistence, gitsigns, grug-far, ts-comments                         |
| `tree.lua`            | neo-tree                                                                                                |
| `treesitter.lua`      | highlighting, folds, indent, textobjects, autotag                                                       |
| `lsp.lua`             | every language server (nil_ls, lua_ls, gopls, pyright, ruff, vtsls, …), venv-selector                     |
| `format.lua`          | conform (format on save) and nvim-lint                                                                  |
| `rust.lua`            | rustaceanvim, crates.nvim (bacon_ls is in `lsp.lua`)                                                    |
| `completion.lua`      | blink.cmp, LuaSnip, friendly-snippets, lazydev                                                          |
| `markdown.lua`        | `leaf` runner, render-markdown, markdown-preview                                                        |
| `swift.lua`           | sourcekit-lsp, SwiftFormat / swift-format, SwiftLint, SwiftPM and xcodebuild.nvim — see [docs/swift.md](docs/swift.md) |
| `vim_tmux_navigator.lua` | `<C-h/j/k/l>` across Neovim splits and tmux panes                                                  |
| `ai.lua`              | CodeCompanion (Gemini 3.8 Flash, MCP servers, skills, rules), img-clip                                  |
| `dap.lua`             | nvim-dap + dap-view / dap-ui, adapters for C/C++/Zig/Rust, Go, Python, JS/TS, Lua                       |
| `testing.lua`         | neotest (Rust, Python, Zig)                                                                             |

## How it boots

1. The wrapper puts the bundled tools on `PATH`, installs plugins in the
   packpath, and runs a short bootstrap (`luaRcContent` in `package.nix`).
2. The bootstrap removes `~/.config/nvim` from the runtimepath so a system
   config can't leak in, adds `config/` in its place, and runs `init.lua`.
3. `init.lua` loads the modules that shape the first frame eagerly, and the
   rest (completion, AI, DAP, tests) on `UIEnter`. In headless mode it loads
   everything immediately so scripts see the full config.

### PATH order

Tools such as language servers and formatters are **prepended** to `PATH`, so
the pinned versions always win. General-purpose runtimes (`go`, `node`, `git`,
`curl`) are **appended**: they are only a fallback, so a project's own
toolchain from direnv, `nix develop` or asdf still wins, including inside
`:terminal`. debugpy's Python is handed to nvim-dap-python by store path and
never goes on `PATH`.

`leaf` is not bundled. `<leader>md` / `<leader>mds` use whichever `leaf` is on
your `PATH`.

---

## Working on the config

```bash
nix develop        # sets NEOVIX_CONFIG=$PWD/config
nvim               # reads Lua straight from the working tree
```

With `NEOVIX_CONFIG` set, the built `nvim` loads Lua from that directory
instead of the store copy, so Lua edits apply on the next launch without a
rebuild. Nix changes (plugins, tools) still need a rebuild.

```bash
nix build .#neovim           # build
nix flake check              # build + headless smoke test
nix flake check --all-systems --no-build   # evaluate every platform
nix fmt                      # alejandra
```

Flakes only see files tracked by git, so run `git add` on new files before
building.

### Add a plugin

1. Add it to the right group in `src/neovim/plugins.nix`
   (`nix search nixpkgs vimPlugins.<name>`).
2. Call its `setup()` in the matching `config/lua/plugins/*.lua`. For a new
   area, create a file and list it in `init.lua`.

### Add a language server, formatter or linter

1. Add the package to a category in `src/neovim/toolchains.nix`.
2. Wire it up:
   - LSP: `vim.lsp.config("<name>", {...})` if it needs settings, and add
     the name to `vim.lsp.enable({...})` in `lsp.lua`.
   - Formatter: `formatters_by_ft` in `format.lua`.
   - Linter: `lint.linters_by_ft` in `format.lua`.
3. Optionally add the binary to the list in `src/neovim/checks/smoke.lua` so
   `nix flake check` guards it.

---

## Using it from another flake

The simplest way is to use the package directly. It is built with neovix's
own pinned nixpkgs:

```nix
# inputs.neovix.url = "github:pplanel/neovix";
environment.systemPackages = [ inputs.neovix.packages.${pkgs.system}.default ];
```

Or use the overlay, which builds against **your** nixpkgs and provides
`pkgs.neovix` (with `pkgs.neovim` aliased to it):

```nix
nixpkgs.overlays = [ inputs.neovix.overlays.default ];
```

The overlay bundles HashiCorp `packer`, which is unfree (BSL), so your nixpkgs
must allow it:

```nix
nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "packer" ];
```

Supported systems: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`.
nixpkgs-unstable no longer supports `x86_64-darwin`.

---

## Key bindings

The leader is `<space>`. The layout follows LazyVim, so the usual keys work;
`<leader>?` shows buffer-local maps and `<leader>sk` searches all of them.

| Keys                                                   | Action                                                          |
| ------------------------------------------------------ | --------------------------------------------------------------- |
| `<leader><space>` `<leader>ff` `<leader>/` `<leader>,` | smart find, files, grep, buffers                                |
| `<leader>e` / `<leader>E`                              | neo-tree (git root / cwd)                                       |
| `gd` `gr` `gI` `gy` `K`                                | definition, references, implementations, type definition, hover |
| `<leader>ca` `<leader>cr` `<leader>cf`                 | code action, rename, format                                     |
| `<leader>uf` / `<leader>uF`                            | toggle format on save (global / buffer)                         |
| `s` / `S`                                              | flash jump / flash treesitter                                   |
| `gsa` `gsd` `gsr`                                      | surround add / delete / replace                                 |
| `]h` `[h` `<leader>gh…`                                | git hunks                                                       |
| `<leader>gg`                                           | gitui                                                           |
| `<leader>xx` `<leader>xt`                              | diagnostics, todos (trouble)                                    |
| `<leader>sr`                                           | search and replace (grug-far)                                   |
| `<leader>a` `<leader>o` `ga` (visual)                  | CodeCompanion: chat, actions, add selection                     |
| `<leader>md` / `<leader>mds`                           | leaf full screen / watch split                                  |
| `<leader>db` `<leader>dc` `<leader>du`                 | breakpoint, continue, dap-view                                  |
| `<leader>tt` `<leader>tr` `<leader>ts`                 | run tests, nearest test, summary                                |
| `<leader>qs`                                           | restore session                                                 |
