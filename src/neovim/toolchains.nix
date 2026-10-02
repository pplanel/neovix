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
  runCommand,
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

  # Only coreutils' stdbuf: the full coreutils would shadow the BSD tools.
  stdbufOnly = runCommand "stdbuf" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.coreutils}/bin/stdbuf $out/bin/stdbuf
  '';

  # ACP bridge for CodeCompanion's claude_code adapter, minus a Claude Code of
  # its own: nixpkgs wraps it around the unfree claude-code package and the
  # Agent SDK bundles a ~200M native copy. Both are dropped; it drives the
  # `claude` already on PATH (set CLAUDE_CODE_EXECUTABLE to pick another).
  claudeAgentAcp = pkgs.claude-agent-acp.overrideAttrs {
    postInstall = ''
      rm -rf $out/lib/node_modules/@agentclientprotocol/claude-agent-acp/node_modules/@anthropic-ai/claude-agent-sdk-*
      wrapProgram $out/bin/claude-agent-acp \
        --run 'if [ -z "''${CLAUDE_CODE_EXECUTABLE-}" ] && claude=$(command -v claude); then export CLAUDE_CODE_EXECUTABLE=$claude; fi'
    '';
  };
in
  with pkgs; {
    core = [
      ripgrep
      fd
      tree-sitter # nvim-treesitter health requires the CLI (parsers come from Nix)
    ];

    lua = [
      lua-language-server
      stylua
    ];

    nix = [
      nil
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
      python3Packages.pylatexenc # latex2text: LaTeX math in render-markdown
      marksman
      markdown-toc
      markdownlint-cli2
      taplo
    ];

    zig = [zls];

    # sourcekit-lsp, swift-format and lldb-dap are deliberately NOT bundled:
    # they must match the compiler that builds the project (nixpkgs ships
    # Swift 5.10; Xcode ships 6.x), so they come from the system toolchain
    # (Xcode via xcrun on macOS, swiftly or distro packages on Linux).
    swift =
      [
        swiftformat
        swiftlint
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        xcbeautify # readable xcodebuild logs (xcodebuild.nvim)
        (callPackage ./pkgs/xcode-build-server.nix {}) # sourcekit-lsp for .xcodeproj
        stdbufOnly # macOS app logs without the debugger (xcodebuild.nvim)
      ];

    ai =
      [
        ast-grep
        claudeAgentAcp
      ]
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
