# The single source of treesitter parsers and queries. nvim-treesitter (main
# branch) ships no parsers of its own; nixpkgs prebuilds every grammar and
# bundles them alongside the plugin, so nothing is compiled at runtime.
{vimPlugins}: vimPlugins.nvim-treesitter.withAllGrammars
