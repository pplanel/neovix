local map = vim.keymap.set
local model = "gemini-3.8-flash"

-- ── CodeCompanion ───────────────────────────────────────────────────────────
require("codecompanion").setup({
  extensions = {
    -- Saved chats live in stdpath("data")/codecompanion-history. Browse: `gh` in a chat
    -- or :CodeCompanionHistory.
    history = {
      enabled = true,
      opts = {
        auto_save = true,
        expiration_days = 0, -- never delete
        picker = "telescope",
        auto_generate_title = true,
        continue_last_chat = false,
      },
    },
  },
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
      -- but when it is unset CodeCompanion passes the literal string, which
      -- claude sends as a bearer token (401). Forward it only when set, so
      -- claude otherwise uses its own login.
      -- claude-agent-acp runs CLAUDE_CODE_EXECUTABLE when set, else `claude` from
      -- PATH. nix-darwin sets it to the personal Claude command on each Mac
      -- (claude-personal on arrakis, where `claude` is the work account).
      claude_code = function()
        return require("codecompanion.adapters").extend("claude_code", {
          env = {
            CLAUDE_CODE_OAUTH_TOKEN = function() return os.getenv("CLAUDE_CODE_OAUTH_TOKEN") end,
            CLAUDE_CODE_EXECUTABLE = function() return os.getenv("CLAUDE_CODE_EXECUTABLE") end,
          },
        })
      end,
      gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {
          env = { GEMINI_API_TOKEN = function() return os.getenv("GEMINI_API_TOKEN") end },
        })
      end,
    },
  },
  -- Chat runs Claude Code over ACP; ACP adapters are chat-only, so inline and cmd stay on Gemini.
  interactions = {
    chat = {
      adapter = "claude_code",
      tools = {
        opts = {
          -- Every chat starts with the developer toolset; no need to type @{developer}.
          default_tools = { "developer" },
        },
        groups = {
          -- Use with `@{developer}` in a chat.
          ["developer"] = {
            description = "Agent suite: shell, file read/edit/search, diagnostics and web tools",
            system_prompt = [[You are an autonomous AI programming agent with access to tools to inspect the environment, read/edit files, and run shell commands.

Guidelines:
1. Always inspect files and search the codebase before suggesting or applying changes.
2. Prefer targeted edits over rewriting entire files.
3. Run tests or build commands to verify changes when applicable.
4. If a tool returns an error, analyze the output and attempt to self-correct.]],
            tools = {
              "run_command",
              "insert_edit_into_file",
              "read_file",
              "create_file",
              "file_search",
              "grep_search",
              "get_changed_files",
              "get_diagnostics",
              "lsp_symbols",
              "fetch_webpage",
              "web_search",
            },
            opts = { collapse_tools = true },
          },
        },
        -- Overrides merge into the built-in tool definitions. Read-only tools run
        -- without a prompt; shell commands, deletes and edits keep theirs. Tavily
        -- reads TAVILY_API_KEY from the environment.
        -- file_search runs on fd (grep_search is already ripgrep-only).
        ["file_search"] = { path = "codecompanion_tools.fd_search" },
        ["lsp_symbols"] = {
          path = "codecompanion_tools.lsp_symbols",
          description = "Symbol outline, workspace symbol search, definitions and references via LSP",
          opts = { require_approval_before = false },
        },
        ["read_file"] = { opts = { require_approval_before = false } },
        ["grep_search"] = { opts = { require_approval_before = false } },
        ["insert_edit_into_file"] = {
          opts = { require_confirmation_after = true },
        },
      },
    },
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
  opts = {
    log_level = "WARN",
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
