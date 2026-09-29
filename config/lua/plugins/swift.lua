-- Swift: sourcekit-lsp, formatting, linting, SwiftPM and Xcode workflows.
--
-- The LSP, Apple's swift-format and lldb-dap come from the system toolchain
-- (Xcode via xcrun on macOS), never from Nix: they must match the compiler
-- that builds the project. Debugging is configured in dap.lua.
local map = vim.keymap.set
local is_mac = vim.fn.has("mac") == 1

---@param path? string
local function xcode_root(path)
  return vim.fs.root(path or 0, function(name) return name:match("%.xcodeproj$") or name:match("%.xcworkspace$") end)
end

---@param path? string
local function package_root(path) return vim.fs.root(path or 0, "Package.swift") end

-- ── LSP ─────────────────────────────────────────────────────────────────────
-- Upstream also claims c/cpp; keep sourcekit to Swift and Objective-C.
vim.lsp.config("sourcekit", {
  cmd = is_mac and { "xcrun", "sourcekit-lsp" } or { "sourcekit-lsp" },
  filetypes = { "swift", "objc", "objcpp" },
})
if (is_mac and vim.fn.executable("xcrun") == 1) or vim.fn.executable("sourcekit-lsp") == 1 then
  vim.lsp.enable("sourcekit")
end

-- ── Xcode projects: stable xcode-build-server path ──────────────────────────
-- `xcode-build-server config` writes its own path into each project's
-- buildServer.json. Point it at a symlink that tracks the current Nix build,
-- so upgrades and garbage collection never leave projects with a dead path.
if is_mac then
  local target = vim.fn.exepath("xcode-build-server")
  if target ~= "" then
    local link = vim.fn.stdpath("data") .. "/neovix/bin/xcode-build-server"
    if vim.uv.fs_readlink(link) ~= target then
      vim.fn.mkdir(vim.fs.dirname(link), "p")
      os.remove(link)
      vim.uv.fs_symlink(target, link)
    end
    vim.env.XCODE_BUILD_SERVER_ARGV0 = link
  end
end

-- ── Formatting & linting ────────────────────────────────────────────────────
-- SwiftFormat by default. Projects that opt into Apple's swift-format (by
-- committing a .swift-format file) get that instead.
local conform = require("conform")
conform.formatters_by_ft.swift = function(buf)
  if vim.fs.root(buf, ".swift-format") then return { "swift_format" } end
  return { "swiftformat" }
end
if is_mac then conform.formatters.swift_format = { command = "xcrun", prepend_args = { "swift-format" } } end

require("lint").linters_by_ft.swift = { "swiftlint" }

-- ── xcodebuild.nvim (macOS) ─────────────────────────────────────────────────
local has_xcodebuild = is_mac and pcall(require, "xcodebuild")
if has_xcodebuild then
  require("xcodebuild").setup({
    integrations = {
      -- Only snacks is installed; the others would just log warnings.
      telescope_nvim = { enabled = false },
      fzf_lua = { enabled = false },
      snacks_nvim = { enabled = true },
      nvim_tree = { enabled = false },
      oil_nvim = { enabled = false },
      -- pymobiledevice3 (physical devices below iOS 17) isn't bundled.
      pymobiledevice = { enabled = false },
    },
  })
end

-- ── Build / run / test ──────────────────────────────────────────────────────
-- One set of keys for both project kinds: an Xcode project goes through
-- xcodebuild.nvim, a Swift package through `swift build|run|test`.
---@param subcommand string e.g. "build" or "package clean"
local function swiftpm(subcommand)
  local root = package_root()
  if not root then return vim.notify("No Package.swift found", vim.log.levels.WARN) end
  local cmd = vim.list_extend({ "swift" }, vim.split(subcommand, " "))
  Snacks.terminal(cmd, { cwd = root, interactive = false, auto_close = false })
end

local function action(xcode_cmd, spm_subcommand)
  return function()
    if has_xcodebuild and xcode_root() then
      vim.cmd(xcode_cmd)
    elseif spm_subcommand then
      swiftpm(spm_subcommand)
    else
      vim.notify(xcode_cmd .. " needs an Xcode project", vim.log.levels.WARN)
    end
  end
end

-- stylua: ignore start
map("n", "<leader>Xb", action("XcodebuildBuild", "build"), { desc = "Build" })
map("n", "<leader>Xr", action("XcodebuildBuildRun", "run"), { desc = "Build & Run" })
map("n", "<leader>Xt", action("XcodebuildTest", "test"), { desc = "Test" })
map("n", "<leader>XC", action("XcodebuildCleanBuild", "package clean"), { desc = "Clean Build" })

if has_xcodebuild then
  map("n", "<leader>XX", "<cmd>XcodebuildPicker<cr>", { desc = "All Xcodebuild Actions" })
  map("n", "<leader>Xs", "<cmd>XcodebuildSetup<cr>", { desc = "Set Up Project" })
  map("n", "<leader>Xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device" })
  map("n", "<leader>XS", "<cmd>XcodebuildSelectScheme<cr>", { desc = "Select Scheme" })
  map("n", "<leader>Xn", "<cmd>XcodebuildTestNearest<cr>", { desc = "Test Nearest" })
  map("n", "<leader>XT", "<cmd>XcodebuildTestClass<cr>", { desc = "Test Class" })
  map("v", "<leader>Xt", "<cmd>XcodebuildTestSelected<cr>", { desc = "Test Selected" })
  map("n", "<leader>Xf", "<cmd>XcodebuildTestFailing<cr>", { desc = "Rerun Failing Tests" })
  map("n", "<leader>Xe", "<cmd>XcodebuildTestExplorerToggle<cr>", { desc = "Test Explorer" })
  map("n", "<leader>Xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Logs" })
  map("n", "<leader>Xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", { desc = "Toggle Code Coverage" })
  map("n", "<leader>XR", "<cmd>XcodebuildShowCodeCoverageReport<cr>", { desc = "Coverage Report" })
  map("n", "<leader>Xp", "<cmd>XcodebuildProjectManager<cr>", { desc = "Project Manager" })
  map("n", "<leader>Xq", "<cmd>XcodebuildQuickfixLine<cr>", { desc = "Quickfix Line" })
  map("n", "<leader>Xa", "<cmd>XcodebuildCodeActions<cr>", { desc = "Xcode Code Actions" })
  map("n", "<leader>Xo", "<cmd>XcodebuildOpenInXcode<cr>", { desc = "Open in Xcode" })
  map("n", "<leader>Xx", "<cmd>XcodebuildCancel<cr>", { desc = "Cancel" })
end
-- stylua: ignore end
