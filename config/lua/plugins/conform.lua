-- return {
--   {
--     "stevearc/conform.nvim",
--     opts = {
--       formatters_by_ft = {
--         nix = { "alejandra" },
--       },
--     },
--   },
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         nil_ls = {
--           formatter = { command = { "alejandra" } },
--         },
--       },
--     },
--   },
-- }
local hostname = vim.fn.hostname()
local has_flake = vim.fn.filereadable(vim.fn.getcwd() .. "/flake.nix") == 1

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "alejandra" },
        sh = { "shfmt" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = { enabled = false },
        -- Replace nil_ls with nixd and pass your options here
        nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }",
              },
              options = has_flake
                  and {
                    -- For nix-darwin system options
                    darwin = {
                      expr = "(builtins.getFlake (toString ./.)).darwinConfigurations.'" .. hostname .. "'.options",
                    },
                    -- For Home Manager options integrated via nix-darwin
                    home_manager = {
                      expr = "(builtins.getFlake (toString ./.)).darwinConfigurations.'"
                        .. hostname
                        .. "'.options.home-manager.users.type.getSubOptions []",
                    },
                  }
                or nil,
            },
          },
        },
      },
    },
  },
}
