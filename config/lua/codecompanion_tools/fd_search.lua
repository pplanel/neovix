-- file_search backed by `fd` instead of the built-in vim.fs.find walk: it is
-- much faster and honours .gitignore. Everything except the search itself
-- (schema, output handlers, approval prompt) is inherited from the built-in tool.
local tool = vim.deepcopy(require("codecompanion.interactions.chat.tools.builtin.file_search"))

local function escape_glob(s) return (s:gsub("[%[%]{}*?\\]", "\\%0")) end

local function search(action, opts)
  local query = action.query
  if not query or query == "" then
    return { status = "error", data = "Query parameter is required and cannot be empty" }
  end
  if vim.fn.executable("fd") ~= 1 then return { status = "error", data = "fd is not installed or not in PATH" } end

  local cwd = vim.fn.getcwd()
  local max_results = action.max_results or (opts and opts.max_results) or 500
  -- fd matches --full-path globs against the absolute path, so anchor the
  -- workspace-relative pattern at the (escaped) cwd.
  local pattern = escape_glob(cwd) .. "/" .. query:gsub("^%./", ""):gsub("^/", "")

  local result = vim
    .system({
      "fd",
      "--glob",
      "--full-path",
      "--type",
      "f",
      "--absolute-path",
      "--max-results",
      tostring(max_results),
      "--",
      pattern,
      cwd,
    }, { text = true, timeout = 30000 })
    :wait()

  if result.code ~= 0 then
    return { status = "error", data = vim.trim(result.stderr ~= "" and result.stderr or "fd failed") }
  end

  local files = vim.split(vim.trim(result.stdout), "\n", { trimempty = true })
  if #files == 0 then
    return { status = "success", data = string.format("No files found matching pattern '%s'", query) }
  end
  return { status = "success", data = files }
end

tool.cmds = {
  function(self, args) return search(args, self.tool.opts) end,
}

return tool
