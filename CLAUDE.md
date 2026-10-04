# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

neovix is a Neovim distribution built entirely by Nix: plugins, treesitter parsers, LSPs, formatters, linters and debug adapters all come from the Nix store. There is no plugin manager (no lazy.nvim, no Mason) and nothing is downloaded at runtime. `README.md` has the full layout, plugin-area table and keymaps.

## Commands

```bash
nix build .#neovim                          # build the package (./result/bin/nvim)
nix flake check                             # build + headless smoke test (the test suite)
nix flake check --all-systems --no-build    # evaluate every supported system
nix build .#checks.<system>.smoke           # run only the smoke test, e.g. aarch64-darwin
nix fmt                                     # alejandra (Nix formatting)
stylua config/                              # Lua formatting (config/stylua.toml: 2 spaces, 120 cols)
nix develop                                 # sets NEOVIX_CONFIG=$PWD/config; then run `nvim`
```

- **Flakes only see git-tracked files.** `git add` new files before building or checking, or they silently won't exist.
- In `nix develop`, the built `nvim` loads Lua from the working tree (`NEOVIX_CONFIG`), so Lua edits need only a relaunch. Changes to `src/neovim/*.nix` (plugins, tools) need a rebuild.

## Architecture

**Two layers of Nix.** `flake/` is the public output surface only (packages, apps, devShells, checks, overlays, formatter), wired per-system in `flake/default.nix`. All implementation lives in `src/neovim/`. Keep that split (see `.agents/skills/nix-flake-organization/SKILL.md`).

**The package (`src/neovim/package.nix`)** calls `wrapNeovimUnstable` with:
- `plugins.nix`: plugins as categorised attrsets, flattened into the packpath, so every plugin is on the runtimepath at startup. Packages missing from nixpkgs live in `src/neovim/pkgs/`.
- `toolchains.nix`: CLI tools grouped by category. Every category is **prepended** to `PATH` (pinned versions win) except `runtimes` (go, node, git, curl…), which is **appended**, so a project's own toolchain from direnv/`nix develop` takes precedence.
- `treesitter.nix`: all grammars prebuilt.
- Only `*.lua` files from `config/` are copied to the store (`lib.fileset`), so non-Lua edits there don't trigger rebuilds.
- `luaRcContent` is the bootstrap. It picks the config dir (`NEOVIX_CONFIG` or the store copy), removes `~/.config/nvim` from the runtimepath, prepends `config/`, sets `vim.g.neovix` (version, config paths, `debugpy_python` store path), then `dofile`s `config/init.lua`.

**The Lua config (`config/`).** "Loading" a plugin just means calling its `setup()`. `config/init.lua` loads modules in two stages:
1. Eager: modules that shape the first frame or must exist before FileType autocmds for files given on the command line (theme, ui, editor, lsp, format, …). Order matters: `plugins.swift` comes after `plugins.format` because it extends conform/nvim-lint.
2. Deferred to `UIEnter`: completion, telescope, ai, dap, testing. Completion goes first so CodeCompanion finds blink.cmp configured. In headless mode everything loads immediately.

Each module is loaded through `pcall`, and a failure surfaces as a notification rather than an abort. A new `config/lua/plugins/*.lua` file does nothing until it's added to one of the lists in `init.lua`.

LSP uses Neovim 0.12 native `vim.lsp.config` / `vim.lsp.enable` in `config/lua/plugins/lsp.lua`. nvim-lspconfig only supplies default configs.

**The smoke test (`src/neovim/checks/smoke.{nix,lua}`)** boots the real package headlessly with a throwaway `HOME`. It fails on any unloadable module, missing toolchain binary, broken treesitter parser, or anything printed to `:messages` during startup. When adding a plugin or tool, add its module or binary to the lists in `smoke.lua`.

## Common changes

- **Plugin:** add it to the right group in `src/neovim/plugins.nix`, then call `setup()` in the matching `config/lua/plugins/*.lua`.
- **LSP/formatter/linter:** add the package to `src/neovim/toolchains.nix`. Then, for an LSP, add `vim.lsp.config(...)` if needed and the name to `vim.lsp.enable({...})` in `lsp.lua`. For a formatter or linter, use `formatters_by_ft` or `lint.linters_by_ft` in `format.lua`.
- `packer` (HashiCorp, BSL) is the only unfree package. It's allowed by name in `flake/default.nix`, and overlay consumers must allow it too.

## Systems and CI

Supported systems: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin` (not `x86_64-darwin`). `.github/workflows/publish-cache.yml` builds aarch64-darwin on pushes to `main` and on tags, and pushes the results to a GHCR binary cache through the reusable workflow in `pplanel/nixcache`. Never commit `secret.key` or `*.secret.key`.
