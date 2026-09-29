-- Debug adapters are Nix-provided: lldb-dap (C/C++/Zig; rustaceanvim picks it
-- up for Rust), delve, debugpy, js-debug-adapter, and osv for Neovim Lua.
-- Swift is the exception: it needs the system toolchain's lldb-dap.
local dap = require("dap")
local map = vim.keymap.set
local icons = require("config.icons").dap

vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
for name, sign in pairs({
  Stopped = { icons.Stopped, "DiagnosticWarn", "DapStoppedLine" },
  Breakpoint = { icons.Breakpoint, "DiagnosticInfo" },
  BreakpointCondition = { icons.BreakpointCondition, "DiagnosticInfo" },
  BreakpointRejected = { icons.BreakpointRejected, "DiagnosticError" },
  LogPoint = { icons.LogPoint, "DiagnosticInfo" },
}) do
  vim.fn.sign_define("Dap" .. name, { text = sign[1], texthl = sign[2], linehl = sign[3], numhl = sign[3] })
end

-- ── Adapters ────────────────────────────────────────────────────────────────
dap.adapters.lldb = { type = "executable", command = "lldb-dap", name = "lldb" }

local lldb_launch = {
  {
    name = "Launch file",
    type = "lldb",
    request = "launch",
    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
  {
    name = "Attach to process",
    type = "lldb",
    request = "attach",
    pid = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}
dap.configurations.c = lldb_launch
dap.configurations.cpp = lldb_launch
dap.configurations.zig = lldb_launch

dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}
dap.configurations.go = {
  { type = "delve", name = "Debug", request = "launch", program = "${file}" },
  {
    type = "delve",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}",
  },
  { type = "delve", name = "Debug package", request = "launch", program = "${fileDirname}" },
}

-- debugpy lives in a dedicated Nix-built interpreter, independent of any venv.
require("dap-python").setup(vim.g.neovix.debugpy_python)

for _, adapter in ipairs({ "pwa-node", "node" }) do
  dap.adapters[adapter] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = "js-debug-adapter", args = { "${port}" } },
  }
end
for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
  dap.configurations[ft] = {
    { type = "pwa-node", request = "launch", name = "Launch file", program = "${file}", cwd = "${workspaceFolder}" },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

-- Swift: must use the toolchain's lldb-dap (the Nix lldb has no Swift
-- support). On macOS xcodebuild.nvim registers the iOS/macOS app config,
-- which it always launches as configurations.swift[1], so SwiftPM goes after.
local swift_lldb = vim.fn.has("mac") == 1 and { command = "xcrun", args = { "lldb-dap" } }
  or { command = vim.fs.joinpath(vim.fs.dirname(vim.fn.exepath("swift")), "lldb-dap") }
dap.adapters["lldb-swift"] = vim.tbl_extend("force", { type = "executable", name = "lldb-swift" }, swift_lldb)

dap.configurations.swift = {}
if package.loaded["xcodebuild"] then
  require("xcodebuild.integrations.dap").setup()
  -- stylua: ignore start
  map("n", "<leader>XD", function() require("xcodebuild.integrations.dap").build_and_debug() end, { desc = "Build & Debug" })
  map("n", "<leader>XB", function() require("xcodebuild.integrations.dap").debug_without_build() end, { desc = "Debug Without Building" })
  map("n", "<leader>XN", function() require("xcodebuild.integrations.dap").debug_func_test() end, { desc = "Debug Nearest Test" })
  -- stylua: ignore end
end
table.insert(dap.configurations.swift, {
  type = "lldb-swift",
  request = "launch",
  name = "Launch SwiftPM executable",
  program = function()
    local root = vim.fs.root(0, "Package.swift") or vim.fn.getcwd()
    return vim.fn.input("Executable: ", root .. "/.build/debug/", "file")
  end,
  cwd = "${workspaceFolder}",
  stopOnEntry = false,
})

-- Neovim Lua (one-small-step-for-vimkind): start a server in the debuggee
-- with <leader>daL, then attach from another instance.
dap.adapters.nlua = function(callback, config)
  callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
end
dap.configurations.lua = {
  { type = "nlua", request = "attach", name = "Attach to running Neovim instance" },
}

-- ── UI ──────────────────────────────────────────────────────────────────────
require("nvim-dap-virtual-text").setup({})
require("dap-view").setup({ auto_toggle = true })
require("dapui").setup()

-- ── Keymaps ─────────────────────────────────────────────────────────────────
-- stylua: ignore start
map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Breakpoint Condition" })
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
map("n", "<leader>dc", function() dap.continue() end, { desc = "Run/Continue" })
map("n", "<leader>da", function()
  local args = vim.split(vim.fn.input("Run with args: "), " ", { trimempty = true })
  local config = vim.deepcopy((dap.configurations[vim.bo.filetype] or {})[1] or {})
  config.args = args
  dap.run(config)
end, { desc = "Run with Args" })
map("n", "<leader>dC", function() dap.run_to_cursor() end, { desc = "Run to Cursor" })
map("n", "<leader>dg", function() dap.goto_() end, { desc = "Go to Line (No Execute)" })
map("n", "<leader>di", function() dap.step_into() end, { desc = "Step Into" })
map("n", "<leader>dj", function() dap.down() end, { desc = "Down" })
map("n", "<leader>dk", function() dap.up() end, { desc = "Up" })
map("n", "<leader>dl", function() dap.run_last() end, { desc = "Run Last" })
map("n", "<leader>do", function() dap.step_out() end, { desc = "Step Out" })
map("n", "<leader>dO", function() dap.step_over() end, { desc = "Step Over" })
map("n", "<leader>dP", function() dap.pause() end, { desc = "Pause" })
map("n", "<leader>ds", function() dap.session() end, { desc = "Session" })
map("n", "<leader>dt", function() dap.terminate() end, { desc = "Terminate" })
map("n", "<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Widgets" })
map("n", "<leader>du", "<cmd>DapViewToggle<cr>", { desc = "Dap View" })
map("n", "<leader>dU", function() require("dapui").toggle({}) end, { desc = "Dap UI" })
map({ "n", "x" }, "<leader>de", function() require("dapui").eval() end, { desc = "Eval" })
map("n", "<leader>dW", "<cmd>DapViewWatch<cr>", { desc = "Watch Expression" })
map("n", "<leader>dpt", function() require("dap-python").test_method() end, { desc = "Debug Python Method" })
map("n", "<leader>dpc", function() require("dap-python").test_class() end, { desc = "Debug Python Class" })
map("n", "<leader>daL", function() require("osv").launch({ port = 8086 }) end, { desc = "Adapter Lua: Launch Server" })
-- stylua: ignore end
