-- The lldb-dap adapter, shared by dap.lua and rustaceanvim (rust.lua).
--
-- By store path, not PATH lookup: a bare name resolves against cwd when PATH
-- lacks it (devshells, GUI launches), so pin the bundled one.
--
-- Started without DEVELOPER_DIR/SDKROOT: Nix dev shells point them at a Nix
-- apple-sdk, where lldb then looks for Apple's debugserver, finds none, and
-- every attach fails ("Failed to attach to the target process"). The debuggee
-- still gets the full dev-shell environment through the runInTerminal launcher.
return {
  type = "executable",
  command = "/usr/bin/env",
  args = { "-u", "DEVELOPER_DIR", "-u", "SDKROOT", vim.g.neovix.lldb_dap },
  name = "lldb",
}
