local map = vim.keymap.set
local icons = require("config.icons")

require("neo-tree").setup({
  close_if_last_window = true,
  sources = { "filesystem", "buffers", "git_status" },
  open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "codecompanion" },
  commands = {
    open_all_files = function(state)
      ---@diagnostic disable-next-line: undefined-field
      local node = state.tree:get_node()
      if node.type ~= "directory" then return end

      local directory = node:get_id()
      local handle = vim.uv.fs_scandir(directory)
      if not handle then return end

      local first = true
      while true do
        local name, type = vim.uv.fs_scandir_next(handle)
        if not name then break end
        if type == "file" then
          local filepath = directory .. "/" .. name
          if first then
            vim.cmd("edit " .. vim.fn.fnameescape(filepath))
            first = false
          else
            vim.cmd("badd " .. vim.fn.fnameescape(filepath))
          end
        end
      end
    end,
  },
  event_handlers = {
    -- Keep the tree visible after opening a file from it.
    {
      event = "file_opened",
      handler = function() require("neo-tree.command").execute({ action = "open" }) end,
    },
  },
  filesystem = {
    bind_to_cwd = false,
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    use_libuv_file_watcher = true,
    filtered_items = {
      hide_dotfiles = false,
    },
  },
  window = {
    mappings = {
      ["O"] = "open_all_files",
      ["l"] = "open",
      ["h"] = "close_node",
      ["<space>"] = "none",
      ["Y"] = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        function(state)
          ---@diagnostic disable-next-line: undefined-field
          local path = state.tree:get_node():get_id()
          vim.fn.setreg("+", path, "c")
          vim.notify("Copied " .. path)
        end,
        desc = "Copy Path to Clipboard",
      },
      ["P"] = { "toggle_preview", config = { use_float = false } },
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true,
      expander_collapsed = icons.ui.chevron_right,
      expander_expanded = icons.ui.chevron_down,
    },
  },
})
-- stylua: ignore start
map("n", "<leader>e", function()
  require("neo-tree.command").execute({ toggle = true, dir = Snacks.git.get_root() or vim.uv.cwd() })
end, { desc = "Explorer NeoTree (Root Dir)" })
map("n", "<leader>E", function() require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() }) end, { desc = "Explorer NeoTree (cwd)" })
map("n", "<leader>ge", function() require("neo-tree.command").execute({ source = "git_status", toggle = true }) end, { desc = "Git Explorer" })
map("n", "<leader>be", function() require("neo-tree.command").execute({ source = "buffers", toggle = true }) end, { desc = "Buffer Explorer" })
-- stylua: ignore end
