# Standalone Neovim Nix Flake & Overlay

A fully reproducible, hermetic Neovim flake and overlay packaging LazyVim, all plugins, and 37+ language servers, formatters, linters, and debuggers directly from the Nix store.

---

## 🌟 Key Highlights

- **100% Offline & Pure**: All plugins are pre-fetched into the Nix store via `pkgs.linkFarm` and loaded locally by `lazy.nvim`. No Git clones or network access needed at runtime.
- **Zero Mason**: Mason is completely disabled. All CLI tools (LSPs, formatters, linters, debug adapters) are managed declaratively in `default.nix` via `extraPackages` and placed on Neovim's wrapped `PATH`.
- **Full LazyVim Support**: Retains the entire LazyVim UI, snacks picker, keymaps, and extras while delegating server lifecycle cleanly to Neovim's native LSP (`vim.lsp.config`).
- **Portable**: Can be built and run standalone with `nix run .#neovim`, or consumed as a flake input and overlay across multiple Darwin or Linux machines.

---

## 📁 Repository Structure

```
.
├── flake.nix             # Flake definition (packages, apps, overlays, devShells)
├── flake.lock            # Pinned nixpkgs commit
├── default.nix           # Wrapped Neovim package with extraPackages & lazyPlugins
├── docs/                 # Architectural specs and implementation plans
└── config/               # Neovim configuration root
    ├── init.lua          # Main entrypoint
    ├── lazyvim.json      # LazyVim extras specification
    ├── lazy-lock.json    # Plugin lockfile
    ├── lua/
    │   ├── config/
    │   │   ├── lazy.lua      # Lazy bootstrap (loads plugins from LAZY_PLUGINS)
    │   │   ├── options.lua   # Editor settings & options
    │   │   ├── keymaps.lua   # Custom keybindings
    │   │   └── autocmds.lua  # Autocommands
    │   └── plugins/          # Custom plugin configs
    │       ├── codecompanion.lua # Gemini 3.8 Flash AI & native MCP
    │       ├── conform.lua       # Formatter config (alejandra, shfmt)
    │       ├── rustacean.lua     # Rust tools & bacon
    │       ├── disabled.lua      # Disabled plugins (mason, etc.)
    │       └── ...
```

---

## 🔨 Building & Running

### Build the package
```bash
nix build .#neovim
```
This generates `./result/bin/nvim`.

### Run directly via Flake
```bash
nix run .#neovim
```

### Enter a shell with this Neovim
```bash
nix develop
```

---

## 📦 How to Add, Remove, or Configure Plugins

### 1. Adding a New Plugin

1. **Find the plugin in Nixpkgs**:
   Search with `nix search nixpkgs vimPlugins.<plugin-name>`.
2. **Add to `default.nix`**:
   Add an entry under the `lazyPlugins = pkgs.linkFarm "lazy-plugins" [ ... ]` list:
   ```nix
   {
     name = "my-plugin.nvim";
     path = vp.my-plugin-nvim;
   }
   ```
   *(Note: `name` must match the repo/folder name expected by Lazy, e.g. `foo.nvim`).*
3. **Configure in Lua**:
   Create or edit `config/lua/plugins/my-plugin.lua`:
   ```lua
   return {
     {
       "author/my-plugin.nvim",
       opts = {
         -- plugin options here
       },
     },
   }
   ```
4. **Rebuild**:
   ```bash
   git add .
   nix build .#neovim
   ```

---

### 2. Disabling or Removing a Plugin

- **To temporarily disable a plugin without removing it**:
  Add it to `config/lua/plugins/disabled.lua`:
  ```lua
  return {
    { "author/plugin-to-disable.nvim", enabled = false },
  }
  ```
- **To permanently remove a plugin**:
  1. Remove its entry from `lazyPlugins` in `default.nix`.
  2. Remove its configuration file from `config/lua/plugins/`.
  3. Rebuild with `git add . && nix build .#neovim`.

---

## 🛠️ How to Add or Manage LSPs, Formatters & Linters

Because Mason is disabled, all binaries come from `extraPackages` in `default.nix`.

### 1. Adding a Tool (e.g., `biome` or `shellcheck`)

1. **Add the package to `default.nix`**:
   Add the nixpkgs attribute to `extraPackages`:
   ```nix
   extraPackages = with pkgs; [
     # ...
     biome
   ];
   ```
2. **Configure Neovim to use it**:
   - **For LSP**: In `config/lua/plugins/lsp.lua` or relevant lang extra:
     ```lua
     return {
       {
         "neovim/nvim-lspconfig",
         opts = {
           servers = {
             biome = {},
           },
         },
       },
     }
     ```
   - **For Formatters**: In `config/lua/plugins/conform.lua`:
     ```lua
     return {
       {
         "stevearc/conform.nvim",
         opts = {
           formatters_by_ft = {
             javascript = { "biome" },
           },
         },
       },
     }
     ```
   - **For Linters**: In `config/lua/plugins/lint.lua`:
     ```lua
     return {
       {
         "mfussenegger/nvim-lint",
         opts = {
           linters_by_ft = {
             javascript = { "biome" },
           },
         },
       },
     }
     ```
3. **Rebuild**:
   ```bash
   git add .
   nix build .#neovim
   ```

---

## ⚙️ Configuring Neovim Settings

- **Options (`options.lua`)**: Edit `config/lua/config/options.lua` to change line numbers, tabs, mouse settings, etc.
- **Keymaps (`keymaps.lua`)**: Edit `config/lua/config/keymaps.lua` to add global keybindings.
- **Autocmds (`autocmds.lua`)**: Edit `config/lua/config/autocmds.lua` for filetype triggers and buffer events.
- **LazyVim Extras (`lazyvim.json`)**: Enable or disable LazyVim extras by editing the `"extras"` array in `config/lazyvim.json`.

---

## 🔗 Consuming in `nix-darwin` or System Flakes

Once you push this repository to GitHub or another Git host:

1. **Add to your system `flake.nix` inputs**:
   ```nix
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
     # Reference your neovim flake:
     neovim-flake.url = "github:<your-username>/neovim";
     # While developing locally, you can use:
     # neovim-flake.url = "git+file:///Users/pplanel/.config/nix-darwin/overlays/neovim";
   };
   ```

2. **Add the overlay to `pkgs`**:
   In your nix-darwin or home-manager configuration:
   ```nix
   nixpkgs.overlays = [
     inputs.neovim-flake.overlays.default
   ];
   ```

3. **Install the package**:
   In `environment.systemPackages` or `home.packages`:
   ```nix
   environment.systemPackages = [
     pkgs.neovim # This will now be your custom wrapped Neovim!
   ];
   ```
