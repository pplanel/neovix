-- nvim-treesitter (main branch) only supplies parsers and queries; all parsers
-- are prebuilt by Nix (src/neovim/treesitter.nix), so there is nothing to
-- install. Features are switched on per buffer when a parser exists.

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("neovix_treesitter", { clear = true }),
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match) or event.match
    if not vim.treesitter.language.add(lang) then return end

    if not pcall(vim.treesitter.start, event.buf, lang) then return end

    if vim.treesitter.query.get(lang, "folds") then vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()" end
    if vim.treesitter.query.get(lang, "indents") then
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- ── textobjects ─────────────────────────────────────────────────────────────
require("nvim-treesitter-textobjects").setup({
  move = { set_jumps = true },
})

local move = require("nvim-treesitter-textobjects.move")
local moves = {
  goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
  goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
  goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
  goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
}
for method, keys in pairs(moves) do
  for key, query in pairs(keys) do
    local desc = (method:gsub("_", " ")):gsub("^goto", "Goto") .. " " .. query:gsub("@", ""):gsub("%..*", "")
    vim.keymap.set({ "n", "x", "o" }, key, function()
      -- In diff mode keep native ]c/[c hunk navigation.
      if vim.wo.diff and key:find("[cC]") then return vim.cmd("normal! " .. key) end
      move[method](query, "textobjects")
    end, { desc = desc, silent = true })
  end
end

-- ── autotag (html/jsx/tsx/vue/...) ──────────────────────────────────────────
require("nvim-ts-autotag").setup()
