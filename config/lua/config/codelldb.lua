-- The CodeLLDB adapter (src/neovim/pkgs/codelldb.nix), shared by dap.lua and
-- rustaceanvim (rust.lua), which treats any "server" adapter as CodeLLDB.
--
-- Started without DEVELOPER_DIR/SDKROOT: Nix dev shells point them at a Nix
-- apple-sdk, where LLDB then looks for Apple's debugserver, finds none, and
-- every launch/attach fails. The debuggee still gets the full environment.
return {
  type = "server",
  host = "127.0.0.1",
  port = "${port}",
  executable = {
    command = "/usr/bin/env",
    args = {
      "-u",
      "DEVELOPER_DIR",
      "-u",
      "SDKROOT",
      vim.g.neovix.codelldb,
      "--liblldb",
      vim.g.neovix.liblldb,
      "--port",
      "${port}",
    },
  },
}
