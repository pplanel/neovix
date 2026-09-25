# Implementation Plan: Standalone Neovim Nix Flake & Overlay

Convert the existing Neovim configuration into a standalone, reproducible Nix Flake located at `/Users/pplanel/.config/nix-darwin/overlays/neovim/`. The flake packages Neovim with all runtime configurations and replaces Mason with a comprehensive Nixpkgs toolchain (`extraPackages`).

## User Review Required

> [!IMPORTANT]
> - Mason plugins (`mason.nvim`, `mason-lspconfig.nvim`, `mason-nvim-dap.nvim`) will be disabled in the new configuration so LazyVim automatically routes all 37 LSPs, formatters, and debuggers to native Neovim LSP and Nixpkgs binaries on `PATH`.
> - The new project in `overlays/neovim` is a standalone Git repository and is added to the parent `nix-darwin/.gitignore`. It can be tested standalone via `nix run .#neovim` and referenced externally in the future.

---

## Proposed Changes

### Component: Neovim Flake Root (`overlays/neovim/`)

#### [NEW] `flake.nix`
Flake definition supporting `aarch64-darwin` (and all default systems via `flake-utils`), exporting `packages.default`, `packages.neovim`, `apps.default`, and `overlays.default`.

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
        neovimPkg = pkgs.callPackage ./default.nix { };
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
        neovim = final.callPackage ./default.nix { };
      };
    };
}
```

#### [NEW] `default.nix`
Derivation wrapping Neovim with `pkgs.wrapNeovimUnstable` using `neovimUtils.makeNeovimConfig`:
- Bundles all 37 Mason replacement CLI tools in `extraPackages`.
- Sets up `customRC` to initialize `config/init.lua` with the copied config in runtimepath.

```nix
{ pkgs, lib ? pkgs.lib, ... }:

let
  extraPackages = with pkgs; [
    # Nix
    nil
    nixd
    alejandra
    statix

    # Rust
    rust-analyzer
    bacon
    lldb

    # Go
    gopls
    delve
    gofumpt
    gotools
    golangci-lint
    gomodifytags
    gotests
    iferr
    impl

    # Python
    pyright
    ruff
    python3Packages.debugpy

    # Web / TypeScript / JSON / YAML
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

    # Markdown, Docs & Formatters
    marksman
    markdown-toc
    markdownlint-cli2
    taplo
    stylua
    tree-sitter

    # Zig & Swift
    zls
    swiftformat

    # Runtime utilities for AI & MCP
    nodejs_22
    curl
    git
  ];

  configDir = ./config;

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    customRC = ''
      set runtimepath^=${configDir}
      set runtimepath+=${configDir}/after
      luafile ${configDir}/init.lua
    '';
  };
in
pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (neovimConfig // {
  wrapperArgs = (neovimConfig.wrapperArgs or []) ++ [
    "--prefix" "PATH" ":" (lib.makeBinPath extraPackages)
  ];
})
```

---

### Component: Runtime Configuration (`overlays/neovim/config/`)

#### [NEW] `config/` (Copied from `~/.config/nvim/`)
- `init.lua`, `lazyvim.json`, `lazy-lock.json`
- `lua/config/` (`lazy.lua`, `options.lua`, `keymaps.lua`, `autocmds.lua`)
- `lua/plugins/` (all existing plugins: `conform.lua`, `rustacean.lua`, `codecompanion.lua`, etc.)

#### [MODIFY] `config/lua/plugins/disabled.lua`
Explicitly disable `mason.nvim`, `mason-lspconfig.nvim`, and `mason-nvim-dap.nvim`:

```lua
return {
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}
```

---

## Verification Plan

### Automated Tests
1. **Build derivation**:
   ```bash
   cd /Users/pplanel/.config/nix-darwin/overlays/neovim && nix build .#neovim
   ```
2. **Headless startup verification**:
   ```bash
   ./result/bin/nvim --headless -c "q"
   ```
3. **Verify tool path resolution**:
   Confirm that binaries resolve to the Nix store rather than `~/.local/share/nvim/mason`:
   ```bash
   ./result/bin/nvim --headless -c "lua print('nixd: ' .. vim.fn.exepath('nixd'))" \
                               -c "lua print('gopls: ' .. vim.fn.exepath('gopls'))" \
                               -c "lua print('rust-analyzer: ' .. vim.fn.exepath('rust-analyzer'))" \
                               -c "lua print('alejandra: ' .. vim.fn.exepath('alejandra'))" \
                               -c "lua print('shfmt: ' .. vim.fn.exepath('shfmt'))" \
                               -c "q"
   ```

### Manual Verification
1. Launch `./result/bin/nvim` inside a terminal.
2. Verify UI elements (Catppuccin theme, Neo-tree, Snacks, Lualine).
3. Open a `.nix` file and run `:LspInfo` to confirm `nixd` attaches.
4. Run `:ConformInfo` to confirm `alejandra` and `shfmt` are available formatters.
