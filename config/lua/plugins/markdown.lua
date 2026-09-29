-- ==========================================
-- 1. FULL BUFFER MODE (<leader>md)
-- ==========================================
return {
  {
    "pplanel/leaf",
    virtual = true,
    keys = {
      {
        "<leader>md",
        function()
          local file = vim.fn.expand("%:p")
          if file == "" or vim.bo.filetype ~= "markdown" then
            vim.notify("Not a valid markdown file", vim.log.levels.WARN)
            return
          end

          -- Create a clean, blank buffer for the terminal
          local term_buf = vim.api.nvim_create_buf(false, true)

          -- Swap the current window to use this clean buffer
          vim.api.nvim_win_set_buf(0, term_buf)

          -- Run leaf inside it using jobstart with term = true
          vim.fn.jobstart("leaf " .. vim.fn.shellescape(file), {
            term = true,
            on_exit = function()
              if vim.api.nvim_buf_is_valid(term_buf) then
                vim.api.nvim_buf_delete(term_buf, { force = true })
              end
            end,
          })

          vim.cmd("startinsert")

          -- Map ESC inside this specific full buffer to close it and drop back to editing
          vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:bd!<CR>", { buffer = term_buf, silent = true })
        end,
        desc = "Toggle Leaf Markdown Full",
      },
      {
        "<leader>mds",
        function()
          local file = vim.fn.expand("%:p")
          if file == "" or vim.bo.filetype ~= "markdown" then
            vim.notify("Not a valid markdown file", vim.log.levels.WARN)
            return
          end

          -- Open the vertical split
          vim.cmd("vsplit")

          -- Create a clean scratch buffer for the split
          local term_buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_win_set_buf(0, term_buf)

          -- Launch leaf with the watch flag (-w) using jobstart
          vim.fn.jobstart("leaf -w " .. vim.fn.shellescape(file), {
            term = true,
            on_exit = function()
              if vim.api.nvim_buf_is_valid(term_buf) then
                vim.api.nvim_buf_delete(term_buf, { force = true })
              end
            end,
          })

          vim.cmd("startinsert")

          -- Map ESC inside the split buffer to close just the preview window
          vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:bd!<CR>", { buffer = term_buf, silent = true })
        end,
        desc = "Leaf Markdown Watch Split",
      },
    },
  },
}
