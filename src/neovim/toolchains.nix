# CLI tools placed on nvim's PATH: language servers, formatters, linters,
# debug adapters and the utilities plugins shell out to. Grouped by domain so
# a category can be inspected (`nix eval .#neovim.toolchains --apply builtins.attrNames`)
# or dropped in one place.
#
# Every category is PREPENDED to PATH (the bundled tool always wins), except
# `runtimes`, which is APPENDED: those are general-purpose interpreters and
# compilers your projects may pin (via direnv, nix develop, asdf...), so the
# bundled copy is only a fallback and never shadows them in :terminal.
{
  lib,
  stdenv,
  pkgs,
  callPackage,
  writeShellScriptBin,
}: let
  wrappers = {
    # nvim-dap expects the adapter under this name; nixpkgs ships `js-debug`.
    js-debug-adapter = writeShellScriptBin "js-debug-adapter" ''
      exec ${pkgs.vscode-js-debug}/bin/js-debug "$@"
    '';

    # terraform-ls and conform's terraform_fmt call `terraform`; OpenTofu is the
    # free implementation.
    terraform = writeShellScriptBin "terraform" ''
      exec ${pkgs.opentofu}/bin/tofu "$@"
    '';
  };
in
  with pkgs; {
    core = [
      ripgrep
      fd
      gitui
    ];

    lua = [
      lua-language-server
      stylua
    ];

    nix = [
      nil
      nixd
      alejandra
      statix
    ];

    rust = [
      rust-analyzer
      bacon
      (callPackage ./pkgs/bacon-ls.nix {})
      lldb
    ];

    go = [
      gopls
      delve
      gofumpt
      gotools
      golangci-lint
      gomodifytags
      gotests
      iferr
      impl
    ];

    # debugpy's interpreter is passed to nvim-dap-python by store path (see
    # package.nix), deliberately kept off PATH so it never shadows `python3`.
    python = [
      pyright
      ruff
    ];

    web = [
      vtsls
      tailwindcss-language-server
      vscode-langservers-extracted
      yaml-language-server
      vscode-js-debug
      prettier
    ];

    shell = [
      bash-language-server
      shellcheck
      shfmt
      fish # fish_indent
      terraform-ls
      tflint
      opentofu
      packer
    ];

    docs = [
      marksman
      markdown-toc
      markdownlint-cli2
      taplo
    ];

    zig = [zls];

    swift = [swiftformat];

    ai =
      [ast-grep]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [pngpaste];

    media = [
      chafa
      viu
      ueberzugpp
      imagemagick
      ghostscript
      tectonic
      mermaid-cli
    ];

    wrappers = lib.attrValues wrappers;

    # Appended to PATH: fallbacks only (see header).
    runtimes = [
      go # gopls/delve/gotests shell out to `go`
      nodejs_22 # npx for CodeCompanion MCP servers
      git
      curl
    ];
  }
