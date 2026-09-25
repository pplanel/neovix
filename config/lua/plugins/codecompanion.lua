return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
    opts = {
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              schema = {
                model = {
                  default = "gemini-3.8-flash",
                },
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          adapter = {
            name = "gemini",
            model = "gemini-3.8-flash",
          },
        },
        inline = {
          adapter = {
            name = "gemini",
            model = "gemini-3.8-flash",
          },
        },
        cmd = {
          adapter = {
            name = "gemini",
            model = "gemini-3.8-flash",
          },
        },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
      },
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
      opts = {
        log_level = "DEBUG",
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
          --- @return boolean
          enabled = function()
            return vim.fn.getcwd():find("pplanel_ssh", 1, true) ~= nil
          end,
          dirs = {
            ".agents/rules/githits_usage.md",
            ".agents/rules/rust_async_patterns.md",
            ".agents/rules/rust_best_practices.md",
          },
        },
      },
    },
    keys = {
      { "<C-a>", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
      {
        "<LocalLeader>a",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion Chat Toggle",
      },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "CodeCompanion Add Selection to Chat" },
    },
    init = function()
      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua",
    config = function()
      require("mcphub").setup({
        use_bundled_binary = true,
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },
  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
}

-- -- MCP Hub extension for CodeCompanion
--
-- -- Markdown rendering in CodeCompanion buffers
-- {
--   "MeanderingProgrammer/render-markdown.nvim",
--   ft = { "markdown", "codecompanion" },
-- },
--
-- -- Paste images into CodeCompanion chat
-- {
--   "HakonHarnes/img-clip.nvim",
--   opts = {
--     filetypes = {
--       codecompanion = {
--         prompt_for_file_name = false,
--         template = "[Image]($FILE_PATH)",
--         use_absolute_path = true,
--       },
--     },
--   },
-- },
--
-- -- Completion integration for blink.cmp
-- {
--   "saghen/blink.cmp",
--   optional = true,
--   opts = {
--     sources = {
--       per_filetype = {
--         codecompanion = { "codecompanion" },
--       },
--     },
--   },
-- },
-- }
