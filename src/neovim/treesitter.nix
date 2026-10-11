# The single source of treesitter parsers and queries. nvim-treesitter (main
# branch) ships no parsers of its own; nixpkgs prebuilds the grammars listed
# here and bundles them alongside the plugin, so nothing is compiled at runtime.
#
# Only languages neovix has tooling for, plus what they inject (regex, comment,
# doc comments, printf) and the files every project has. Anything else falls
# back to Vim's regex syntax. Add a grammar here when adding a language.
{vimPlugins}:
vimPlugins.nvim-treesitter.withPlugins (p:
    with p; [
      # Neovim itself
      lua
      luadoc
      luap
      query
      vim
      vimdoc

      # Languages with LSP/formatter/debugger support (toolchains.nix)
      bash
      c
      cpp
      css
      fish
      go
      gomod
      gosum
      gowork
      hcl
      html
      javascript
      jsdoc
      json
      json5
      nix
      python
      rust
      scss
      swift
      terraform
      tsx
      typescript
      zig

      # Docs and config formats
      csv
      dockerfile
      editorconfig
      ini
      just
      latex
      make
      markdown
      markdown_inline
      mermaid
      proto
      sql
      ssh_config
      toml
      xml
      yaml

      # Git
      diff
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore

      # Injected into other languages
      comment
      printf
      regex
    ])
