return {
  {
    "igorlfs/nvim-dap-view",
    dependencies = { "mfussenegger/nvim-dap" },
    cmd = { "DapViewOpen", "DapViewClose", "DapViewToggle", "DapViewWatch" },
    ---@module 'dap-view'
    ---@type dapview.Config
    opts = {},
  },
}
