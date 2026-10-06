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
    acp = {
      -- The preset maps CLAUDE_CODE_OAUTH_TOKEN to the env var of that name,
      -- but when it is unset CodeCompanion passes the literal string, which A
      -- claude sends as a bearer token (401). Forward it only when set, so
      -- claude otherwise uses its own login.
      claude_code = function()
        return require("codecompanion.adapters").extend("claude_code", {
          env = { CLAUDE_CODE_OAUTH_TOKEN = function() return os.getenv("CLAUDE_CODE_OAUTH_TOKEN") end },
        })
      end,
      gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {
          env = { GEMINI_API_TOKEN = function() return os.getenv("GEMINI_API_TOKEN") end },
        })
      end,
    },
  },
  -- Chat runs Claude Code over ACP (claude-agent-acp drives the `claude` on
  -- PATH); ACP adapters are chat-only, so inline and cmd stay on Gemini.
  interactions = {
    chat = { adapter = "gemini" },
    inline = { adapter = { name = "gemini", model = model } },
    cmd = { adapter = { name = "gemini_cli", model = model } },
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
      ["linear"] = {
        cmd = { "npx", "-y", "mcp-remote", "https://mcp.linear.app/mcp" },
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
    -- rust_rules = {
    --   description = "Rules for Rust projects",
    --   ---@return boolean
    --   enabled = function() return vim.fn.getcwd():find("pplanel_ssh", 1, true) ~= nil end,
    --   dirs = {
    --     ".agents/rules/githits_usage.md",
    --     ".agents/rules/rust_async_patterns.md",
    --     ".agents/rules/rust_best_practices.md",
    --   },
    -- },
  },
  srategies = {
    chat = {
      -- ...existing code...
      tools = {
        opts = {
          auto_submit_errors = true,
          auto_submit_success = true,
          system_prompt = [[You are an autonomous AI programming agent. You have access to tools to inspect the environment, read/edit files, and execute shell commands.

Guidelines:
1. Always inspect files and search the codebase before suggesting or applying changes.
2. Use the editor tool to apply targeted edits rather than rewriting entire files when possible.
3. Run tests or build commands with the cmd_runner tool to verify changes when applicable.
4. If a tool returns an error, analyze the error output and attempt to self-correct.]],
        },
        groups = {
          ["developer"] = {
            description = "Full agent suite with shell, editor, buffer, file search, and web tools",
            system_prompt = "You are an autonomous software engineer with full access to project tools.",
            tools = {
              "cmd_runner",
              "editor",
              "files",
              "buffer",
              "grep",
              "fetch_web_content",
            },
          },
        },
        ["cmd_runner"] = {
          opts = {
            requires_approval = false,
          },
        },
        ["editor"] = {
          opts = {
            requires_approval = true,
          },
        },
        ["files"] = {},
        ["buffer"] = {},
        ["grep"] = {},
        ["fetch_web_content"] = {},
        ["web_search"] = {
          opts = {
            adapter = "tavily", -- or "brave", "serpapi", "google"
            params = {
              api_key = "TAVILY_API_KEY",
            },
          },
        },
      },
    },
    inline = {
      -- ...existing code...
    },
  },
  srategies = {
    chat = {
      -- ...existing code...
      tools = {
        opts = {
          auto_submit_errors = true,
          auto_submit_success = true,
          system_prompt = [[You are an autonomous AI programming agent. You have access to tools to inspect the environment, read/edit files, and execute shell commands.

Guidelines:
1. Always inspect files and search the codebase before suggesting or applying changes.
2. Use the editor tool to apply targeted edits rather than rewriting entire files when possible.
3. Run tests or build commands with the cmd_runner tool to verify changes when applicable.
4. If a tool returns an error, analyze the error output and attempt to self-correct.]],
        },
        groups = {
          ["developer"] = {
            description = "Full agent suite with shell, editor, buffer, file search, and web tools",
            system_prompt = "You are an autonomous software engineer with full access to project tools.",
            tools = {
              "cmd_runner",
              "editor",
              "files",
              "buffer",
              "grep",
              "fetch_web_content",
            },
          },
        },
        ["cmd_runner"] = {
          opts = {
            requires_approval = true,
          },
        },
        ["editor"] = {
          opts = {
            requires_approval = true,
          },
        },
        ["files"] = {},
        ["buffer"] = {},
        ["grep"] = {},
        ["fetch_web_content"] = {},
        ["web_search"] = {
          opts = {
            adapter = "tavily", -- or "brave", "serpapi", "google"
            params = {
              api_key = "TAVILY_API_KEY",
            },
          },
        },
      },
    },
    inline = {
      -- ...existing code...
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
