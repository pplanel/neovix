-- Boots headlessly inside the real package and fails on any error:
-- unloadable modules, missing toolchain binaries, broken treesitter parsers,
-- or anything printed to :messages during startup.
local failures = {}
local function check(ok, what)
	if not ok then
		table.insert(failures, what)
	end
end

for _, mod in ipairs({
	"retro82",
	"onedark",
	"snacks",
	"which-key",
	"lualine",
	"bufferline",
	"neo-tree",
	"blink.cmp",
	"luasnip",
	"conform",
	"lint",
	"lspconfig",
	"rustaceanvim",
	"crates",
	"render-markdown",
	"dap",
	"dap-view",
	"dapui",
	"neotest",
	"noice",
	"telescope",
	"flash",
	"gitsigns",
	"grug-far",
	"trouble",
	"mini.ai",
	"nvim-treesitter",
	"treesitter-context",
	"nvim-treesitter-textobjects",
	"persistence",
	"schemastore",
	"github-actions",
}) do
	check(pcall(require, mod), "require " .. mod)
end

for _, bin in ipairs({
	"rg",
	"fd",
	"nil",
	"alejandra",
	"rust-analyzer",
	"bacon-ls",
	"lldb-dap",
	"lua-language-server",
	"stylua",
	"gopls",
	"dlv",
	"pyright",
	"ruff",
	"vtsls",
	"js-debug-adapter",
	"terraform",
	"shfmt",
	"prettier",
	"marksman",
	"npx",
	"go",
	"swiftformat",
	"swiftlint",
}) do
	check(vim.fn.executable(bin) == 1, "executable " .. bin)
end
-- DAP adapters launched by store path rather than PATH lookup.
check(vim.fn.executable(vim.g.neovix.lldb_dap) == 1, "executable vim.g.neovix.lldb_dap")

-- A sample of the allowlist in src/neovim/treesitter.nix, injections included.
for _, lang in ipairs({
	"rust",
	"nix",
	"lua",
	"python",
	"go",
	"typescript",
	"tsx",
	"markdown",
	"markdown_inline",
	"bash",
	"json",
	"yaml",
	"toml",
	"vimdoc",
	"regex",
	"comment",
}) do
	check(
		pcall(vim.treesitter.language.add, lang) and vim.treesitter.query.get(lang, "highlights") ~= nil,
		"treesitter " .. lang
	)
end

-- Opening real files runs FileType autocmds, treesitter and LSP root
-- detection (gopls shells out to `go` here, which once broke every .go file).
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
for name, body in pairs({
	["main.go"] = "package main\n\nfunc main() {}\n",
	["main.rs"] = "fn main() {}\n",
	["default.nix"] = "{ }\n",
	["init.lua"] = "return {}\n",
	["main.swift"] = 'print("hi")\n',
}) do
	local path = tmp .. "/" .. name
	vim.fn.writefile(vim.split(body, "\n"), path)
	local ok, err = pcall(vim.cmd.edit, path)
	check(ok, "open " .. name .. ": " .. tostring(err))
	check(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil, "highlight " .. name)
end

-- .vscode/launch.json (dap.lua): found upward from the buffer, JSONC with
-- trailing commas, ${workspaceFolder} rebased, VS Code type names resolvable.
do
	local dap = require("dap")
	local root = tmp .. "/proj"
	vim.fn.mkdir(root .. "/.vscode", "p")
	vim.fn.mkdir(root .. "/src", "p")
	vim.fn.writefile({
		"{",
		"  // CodeLLDB style",
		'  "configurations": [',
		'    { "type": "lldb", "request": "launch", "name": "cargo",',
		'      "cargo": { "args": ["build"] }, "cwd": "${workspaceFolder}", },',
		'    { "type": "lldb-dap", "request": "launch", "name": "prebuilt",',
		'      "program": "${workspaceFolder}/target/debug/x", },',
		"  ],",
		"}",
	}, root .. "/.vscode/launch.json")
	vim.fn.writefile({ "fn main() {}" }, root .. "/src/lib.rs")
	vim.cmd.edit(root .. "/src/lib.rs")
	local real = vim.uv.fs_realpath(root)
	local ok, configs = pcall(dap.providers.configs["dap.launch.json"], vim.api.nvim_get_current_buf())
	check(ok and #configs == 2, "launch.json configs (got " .. vim.inspect(configs) .. ")")
	if ok and #configs == 2 then
		check(configs[1].cwd == real, "launch.json ${workspaceFolder} cwd (got " .. tostring(configs[1].cwd) .. ")")
		check(configs[2].program == real .. "/target/debug/x", "launch.json ${workspaceFolder} program")
	end
	for _, type in ipairs({ "lldb", "lldb-dap", "codelldb", "go", "python", "pwa-node" }) do
		check(dap.adapters[type] ~= nil, "dap adapter " .. type)
	end
	check(dap.listeners.on_config["neovix.codelldb"] ~= nil, "dap codelldb cargo listener")
	-- config/lldb.lua: dev shells' DEVELOPER_DIR/SDKROOT must not reach lldb-dap.
	local lldb = dap.adapters.lldb or {}
	check(
		vim.list_contains(lldb.args or {}, "DEVELOPER_DIR")
			and vim.list_contains(lldb.args or {}, vim.g.neovix.lldb_dap),
		"lldb adapter strips DEVELOPER_DIR (got " .. vim.inspect(lldb) .. ")"
	)
end

-- autocmds.lua follows the focused buffer's project root.
do
	local proj = tmp .. "/cwdproj"
	vim.fn.mkdir(proj .. "/src", "p")
	vim.fn.writefile({ "" }, proj .. "/Cargo.toml")
	vim.fn.writefile({ "fn main() {}" }, proj .. "/src/main.rs")
	vim.cmd.edit(proj .. "/src/main.rs")
	local real = vim.uv.fs_realpath(proj)
	check(vim.uv.fs_realpath(vim.fn.getcwd()) == real, "cwd follows buffer (got " .. vim.fn.getcwd() .. ")")
end

-- Optional features (src/neovim/package.nix): check whatever is enabled.
local features = vim.g.neovix.features
if features.codecompanion then
	for _, mod in ipairs({ "codecompanion", "codecompanion._extensions.history", "img-clip" }) do
		check(pcall(require, mod), "require " .. mod)
	end
	check(vim.fn.executable("claude-agent-acp") == 1, "executable claude-agent-acp")
end
if features.claudecode then
	check(pcall(require, "claudecode"), "require claudecode")
	check(vim.fn.exists(":ClaudeCode") == 2, "claudecode commands")
	for _, m in ipairs({ { "n", "<C-,>" }, { "x", "<C-,>" }, { "n", "<leader>ap" }, { "n", "<leader>aD" } }) do
		check(vim.fn.maparg(m[2], m[1]) ~= "", "claudecode map " .. m[1] .. " " .. m[2])
	end
	-- vim.tbl_get: an uncaught error here would hang the check instead of failing it.
	check(type(vim.tbl_get(Snacks.config, "picker", "actions", "claude_add")) == "function", "snacks picker claude_add")
	check(#vim.api.nvim_get_autocmds({ group = "neovix_claudecode_tree" }) > 0, "claudecode neo-tree <leader>as")
end

check(vim.fn.exists(":TmuxNavigateLeft") == 2, "vim-tmux-navigator commands")
check(vim.fn.maparg("<c-h>", "n"):find("TmuxNavigateLeft") ~= nil, "<c-h> mapped to tmux navigator")
check(vim.fn.exists(":GithubActionsHistory") == 2, "github-actions commands")

if vim.fn.has("mac") == 1 then
	check(pcall(require, "xcodebuild"), "require xcodebuild")
	for _, bin in ipairs({ "xcode-build-server", "xcbeautify", "stdbuf" }) do
		check(vim.fn.executable(bin) == 1, "executable " .. bin)
	end
end

check(vim.g.colors_name == "onedark", "colorscheme (got " .. tostring(vim.g.colors_name) .. ")")
check(#vim.lsp.get_configs({ enabled = true }) > 10, "lsp configs enabled")

local errors = vim.fn.execute("messages")
check(not errors:find("E%d+:") and not errors:find("neovix: failed"), "startup messages:\n" .. errors)

if #failures > 0 then
	io.stderr:write("neovix smoke test failed:\n  " .. table.concat(failures, "\n  ") .. "\n")
	vim.cmd("cquit 1")
end
io.stdout:write("neovix smoke test passed\n")
vim.cmd("qall!")
