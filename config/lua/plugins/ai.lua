local map = vim.keymap.set
local model = "gemini-3.8-flash"

-- ── CodeCompanion ───────────────────────────────────────────────────────────
require("codecompanion").setup({
  adapters = {
    http = {
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          schema = { model = { default = model } },
        })
      end,
    },
  },
  interactions = {
    chat = { adapter = { name = "gemini", model = model } },
    inline = { adapter = { name = "gemini", model = model } },
    cmd = { adapter = { name = "gemini", model = model } },
  },
  -- MCP servers run through npx (nodejs_22 is bundled on PATH).
  mcp = {
    servers = {
      ["shadow-pty"] = {
        cmd = { "npx", "-y", "@azimovlabs/mcp-shadow-pty" },
      },
      ["GitHits"] = {
        cmd = { "npx", "-y", "githits@latest", "mcp", "start" },
      },
    },
  },
  skills = {
    dirs = {
      "~/.agents/skills/",
      ".agents/skills/",
    },
  },
  rules = {
    rust_rules = {
      description = "Rules for Rust projects",
      ---@return boolean
      enabled = function() return vim.fn.getcwd():find("pplanel_ssh", 1, true) ~= nil end,
      dirs = {
        ".agents/rules/githits_usage.md",
        ".agents/rules/rust_async_patterns.md",
        ".agents/rules/rust_best_practices.md",
      },
    },
  },
  opts = {
    log_level = "DEBUG",
  },
})

-- stylua: ignore start
map({ "n", "v" }, "<leader>o", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
map({ "n", "v" }, "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "CodeCompanion Chat Toggle" })
map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { desc = "CodeCompanion Add Selection to Chat" })
-- stylua: ignore end

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

-- ── img-clip: paste screenshots into chats (pngpaste on macOS) ─────────────
require("img-clip").setup({
  filetypes = {
    codecompanion = {
      prompt_for_file_name = false,
      template = "[Image]($FILE_PATH)",
      use_absolute_path = true,
    },
  },
})
map("n", "<leader>P", "<cmd>PasteImage<cr>", { desc = "Paste Image from Clipboard" })
