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
	"catppuccin",
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
	"codecompanion",
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
	"nvim-treesitter-textobjects",
	"persistence",
	"schemastore",
}) do
	check(pcall(require, mod), "require " .. mod)
end

for _, bin in ipairs({
	"rg",
	"fd",
	"nixd",
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

for _, lang in ipairs({ "rust", "nix", "lua", "python", "go", "typescript", "markdown", "bash" }) do
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

check(vim.fn.exists(":TmuxNavigateLeft") == 2, "vim-tmux-navigator commands")
check(vim.fn.maparg("<c-h>", "n"):find("TmuxNavigateLeft") ~= nil, "<c-h> mapped to tmux navigator")

if vim.fn.has("mac") == 1 then
	check(pcall(require, "xcodebuild"), "require xcodebuild")
	for _, bin in ipairs({ "xcode-build-server", "xcbeautify", "stdbuf" }) do
		check(vim.fn.executable(bin) == 1, "executable " .. bin)
	end
end

check(
	vim.g.colors_name == "catppuccin-mocha" or vim.g.colors_name == "catppuccin-latte",
	"colorscheme (got " .. tostring(vim.g.colors_name) .. ")"
)
check(#vim.lsp.get_configs({ enabled = true }) > 10, "lsp configs enabled")

local errors = vim.fn.execute("messages")
check(not errors:find("E%d+:") and not errors:find("neovix: failed"), "startup messages:\n" .. errors)

if #failures > 0 then
	io.stderr:write("neovix smoke test failed:\n  " .. table.concat(failures, "\n  ") .. "\n")
	vim.cmd("cquit 1")
end
io.stdout:write("neovix smoke test passed\n")
vim.cmd("qall!")
