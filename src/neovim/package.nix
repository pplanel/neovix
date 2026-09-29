{
  lib,
  pkgs,
  neovim-unwrapped,
  wrapNeovimUnstable,
  python3,
  vimPlugins,
}: let
  # Plain `import` rather than callPackage: these return categorised attrsets
  # whose values are flattened below, so callPackage's `override` attrs must not
  # leak in.
  plugins = import ./plugins.nix {
    inherit lib vimPlugins;
    inherit (pkgs) stdenv callPackage;
  };
  toolchains = import ./toolchains.nix {
    inherit lib pkgs;
    inherit (pkgs) stdenv callPackage runCommand writeShellScriptBin;
  };
  treesitter = import ./treesitter.nix {inherit vimPlugins;};

  # Only Lua reaches the store, so README/stylua/etc. edits don't trigger a rebuild.
  config = lib.fileset.toSource {
    root = ../../config;
    fileset = lib.fileset.fileFilter (file: file.hasExt "lua") ../../config;
  };

  debugpyPython = python3.withPackages (ps: [ps.debugpy]);

  # Bootstrap: pick the config dir, isolate from ~/.config/nvim, hand off to init.lua.
  # Set NEOVIX_CONFIG to a checkout's config/ to iterate on Lua without rebuilding.
  luaRcContent = ''
    vim.g.neovix_start = vim.uv.hrtime()
    vim.loader.enable()

    local store_config = "${config}"
    local config_dir = vim.env.NEOVIX_CONFIG
    if not config_dir or config_dir == "" or vim.fn.isdirectory(config_dir) == 0 then
      config_dir = store_config
    end

    vim.g.neovix = {
      version = "${neovim-unwrapped.version}",
      config = config_dir,
      store_config = store_config,
      debugpy_python = "${debugpyPython}/bin/python",
    }

    local user_config = vim.fn.stdpath("config")
    vim.opt.runtimepath:remove(user_config)
    vim.opt.runtimepath:remove(user_config .. "/after")
    vim.opt.runtimepath:prepend(config_dir)
    vim.opt.runtimepath:append(config_dir .. "/after")

    dofile(config_dir .. "/init.lua")
  '';
in
  (wrapNeovimUnstable neovim-unwrapped {
    inherit luaRcContent;
    plugins = lib.flatten (lib.attrValues plugins) ++ [treesitter];
    extraLuaPackages = ps: [ps.jsregexp]; # LuaSnip transformations
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    wrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath (lib.flatten (lib.attrValues (removeAttrs toolchains ["runtimes"]))))
      "--suffix"
      "PATH"
      ":"
      (lib.makeBinPath toolchains.runtimes)
    ];
  }).overrideAttrs (old: {
    passthru =
      (old.passthru or {})
      // {
        inherit plugins toolchains treesitter config;
      };
    meta =
      (old.meta or {})
      // {
        description = "neovix: pure Nix-managed Neovim with bundled toolchains";
        mainProgram = "nvim";
      };
  })
