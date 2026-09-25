# Design Spec: Standalone Neovim Nix Flake & Overlay

## 1. Overview & Context

This repository is a standalone, fully reproducible Nix Flake for Neovim. It replaces mutable plugins and Mason-downloaded binaries with Nixpkgs packages and declarative plugin configuration.

This repository will eventually be pushed to an external Git forge (e.g. GitHub) and referenced in the `nix-darwin` system flake via:
```nix
inputs.neovim.url = "github:<user>/neovim"; # or git+file:///...
```

### Key Principles
1. **Zero Mason Dependence**: All 37 CLI tools, LSPs, formatters, and debug adapters are provided via `nixpkgs` and injected into Neovim's wrapped `PATH`.
2. **Native LazyVim Compatibility**: LazyVim natively bypasses Mason when `mason.nvim` and `mason-lspconfig.nvim` are disabled, routing all LSP servers to `vim.lsp.config(server, sopts)` and `vim.lsp.enable(server)`, and formatters/linters to system `$PATH`.
3. **Hermetic & Portable**: Operates standalone with `nix run`, `nix build`, or as an overlay `overlays.default = final: prev: { neovim = ...; }`.

---

## 2. Architecture & File Structure

```
.
├── .git/                 # Git repository
├── flake.nix             # Flake definition (packages, apps, overlays, devShell)
├── flake.lock            # Nixpkgs pin
├── default.nix           # Wrapped Neovim package derivation
├── docs/
│   └── superpowers/
│       ├── specs/
│       └── plans/
└── config/               # Neovim configuration root
    ├── init.lua          # Entrypoint setting runtimepath and booting config
    ├── lazy-lock.json    # Pinned plugin lockfile
    ├── lazyvim.json      # LazyVim extras specification
    ├── lua/
    │   ├── config/
    │   │   ├── lazy.lua      # Lazy.nvim setup with Mason disabled
    │   │   ├── options.lua   # Core editor options
    │   │   ├── keymaps.lua   # Key mappings
    │   │   └── autocmds.lua  # Autocommands
    │   └── plugins/          # User plugin overrides
    │       ├── conform.lua       # Formatter config (alejandra, shfmt)
    │       ├── rustacean.lua     # Rust tools & bacon
    │       ├── codecompanion.lua # Gemini 3.8 Flash AI & MCP
    │       ├── dap_view.lua      # DAP view config
    │       ├── neotree.lua       # Neo-tree settings
    │       ├── neotest.lua       # Neotest settings
    │       ├── markdown.lua      # Render-markdown
    │       ├── crates.lua        # Cargo crates
    │       ├── theme.lua         # Catppuccin theme
    │       ├── vim_tmux_navigator.lua
    │       ├── web-devicons.lua
    │       └── disabled.lua      # Explicitly disables mason, mason-lspconfig, mason-nvim-dap
```

---

## 3. Toolchain & Nixpkgs Package Matrix (`extraPackages`)

Neovim is wrapped using `pkgs.wrapNeovimUnstable` with all required binaries on `PATH`:

| Category | Tools | Nixpkgs Packages |
| :--- | :--- | :--- |
| **Nix** | `nil`, `nixd`, `alejandra`, `statix` | `pkgs.nil`, `pkgs.nixd`, `pkgs.alejandra`, `pkgs.statix` |
| **Rust** | `rust-analyzer`, `bacon`, `codelldb` | `pkgs.rust-analyzer`, `pkgs.bacon`, `pkgs.lldb` |
| **Go** | `gopls`, `dlv`, `gofumpt`, `goimports`, `golangci-lint`, `gomodifytags`, `gotests`, `iferr`, `impl` | `pkgs.gopls`, `pkgs.delve`, `pkgs.gofumpt`, `pkgs.gotools`, `pkgs.golangci-lint`, `pkgs.gomodifytags`, `pkgs.gotests`, `pkgs.iferr`, `pkgs.impl` |
| **Python** | `pyright`, `ruff`, `debugpy` | `pkgs.pyright`, `pkgs.ruff`, `pkgs.python3Packages.debugpy` |
| **Web / TS / UI** | `vtsls`, `tailwindcss-language-server`, `vscode-json-language-server`, `yaml-language-server`, `js-debug-adapter` | `pkgs.vtsls`, `pkgs.tailwindcss-language-server`, `pkgs.vscode-langservers-extracted`, `pkgs.yaml-language-server`, `pkgs.vscode-js-debug` |
| **Shell & Infra** | `bash-language-server`, `shellcheck`, `shfmt`, `terraform-ls`, `tflint` | `pkgs.bash-language-server`, `pkgs.shellcheck`, `pkgs.shfmt`, `pkgs.terraform-ls`, `pkgs.tflint` |
| **Docs & Config** | `marksman`, `markdown-toc`, `markdownlint-cli2`, `taplo`, `stylua`, `tree-sitter` | `pkgs.marksman`, `pkgs.markdown-toc`, `pkgs.markdownlint-cli2`, `pkgs.taplo`, `pkgs.stylua`, `pkgs.tree-sitter` |
| **Zig & Swift** | `zls`, `swiftformat` | `pkgs.zls`, `pkgs.swiftformat` |
| **AI / MCP Runtimes** | `nodejs`, `curl` | `pkgs.nodejs_22`, `pkgs.curl` |

---

## 4. Mason Disabling in LazyVim

In `config/lua/plugins/disabled.lua`:
```lua
return {
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}
```

LazyVim detects Mason is disabled and automatically delegates server lifecycle to native Neovim LSP and PATH resolution.

---

## 5. Overlay & Flake Interface

### `flake.nix`
```nix
{
  description = "Standalone Neovim Flake with bundled Nixpkgs toolchains";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        neovimPkg = import ./default.nix { inherit pkgs; };
      in {
        packages.default = neovimPkg;
        packages.neovim = neovimPkg;
        apps.default = {
          type = "app";
          program = "${neovimPkg}/bin/nvim";
        };
      }
    ) // {
      overlays.default = final: prev: {
        neovim = import ./default.nix { pkgs = final; };
      };
    };
}
```

---

## 6. Verification Plan

1. `nix build .#neovim` builds cleanly.
2. `./result/bin/nvim --headless -c "q"` starts and exits cleanly without Lua errors.
3. Language servers and formatters are confirmed reachable in PATH via `./result/bin/nvim --headless -c "lua print(vim.fn.exepath('nixd'))" -c "q"`.
