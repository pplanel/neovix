local map = vim.keymap.set
local icons = require("config.icons")

-- ── mini.nvim: textobjects, surround, pairs ─────────────────────────────────
local ai = require("mini.ai")
ai.setup({
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter({
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
    d = { "%f[%d]%d+" },
    u = ai.gen_spec.function_call(),
    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
  },
})

-- LazyVim's mini-surround extra keys (gs prefix keeps `s` free for flash)
require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
  },
})

require("mini.pairs").setup({
  modes = { insert = true, command = true, terminal = false },
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  skip_ts = { "string" },
  skip_unbalanced = true,
  markdown = true,
})

-- ── flash ───────────────────────────────────────────────────────────────────
require("flash").setup()
-- stylua: ignore start
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
map({ "n", "o", "x" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
map("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
map("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })
-- stylua: ignore end

-- ── persistence (sessions) ──────────────────────────────────────────────────
require("persistence").setup()
-- stylua: ignore start
map("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore Session" })
map("n", "<leader>qS", function() require("persistence").select() end, { desc = "Select Session" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore Last Session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't Save Current Session" })
-- stylua: ignore end

-- ── gitsigns ────────────────────────────────────────────────────────────────
require("gitsigns").setup({
  signs = {
    add = { text = icons.git.added },
    change = { text = icons.git.changed },
    delete = { text = icons.git.deleted },
    topdelete = { text = icons.git.deleted },
    changedelete = { text = icons.git.changed },
    untracked = { text = icons.git.added },
  },
  on_attach = function(buffer)
    local gs = require("gitsigns")
    local function bmap(mode, l, r, desc) map(mode, l, r, { buffer = buffer, desc = desc }) end

    -- stylua: ignore start
    bmap("n", "]h", function()
      if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
    end, "Next Hunk")
    bmap("n", "[h", function()
      if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
    end, "Prev Hunk")
    bmap("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
    bmap("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
    bmap({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
    bmap({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
    bmap("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
    bmap("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
    bmap("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    bmap("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
    bmap("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
    bmap("n", "<leader>ghd", gs.diffthis, "Diff This")
    bmap("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
    bmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
    -- stylua: ignore end
  end,
})

-- ── grug-far (search & replace) ─────────────────────────────────────────────
require("grug-far").setup({ headerMaxWidth = 80 })
map({ "n", "v" }, "<leader>sr", function()
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  require("grug-far").open({
    transient = true,
    prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
  })
end, { desc = "Search and Replace" })

-- ── ts-comments (treesitter-aware commentstring for gc) ────────────────────
require("ts-comments").setup()
