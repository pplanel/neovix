-- Semantic code navigation through the running language servers: document and
-- workspace symbols, go-to-definition and find-references. Gives the agent
-- exact answers where it would otherwise grep.
local log = require("codecompanion.utils.log")

local fmt = string.format

local MAX_ITEMS = 100
local ATTACH_RETRIES = 40 -- x 250ms: servers (rust-analyzer, sourcekit...) can be slow to attach

---Load a file into a hidden buffer and let FileType autocmds attach LSP clients to it.
---@param path string
---@return integer|nil bufnr, string|nil err
local function load_buffer(path)
  path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  if vim.fn.filereadable(path) ~= 1 then return nil, fmt("`%s` does not exist or is not a file", path) end
  local bufnr = vim.fn.bufadd(path)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
    local ft = vim.filetype.match({ buf = bufnr, filename = path })
    if ft then vim.bo[bufnr].filetype = ft end
  end
  return bufnr
end

---Call `cb` once a client is attached to `bufnr`, or with false after the retries run out.
local function when_attached(bufnr, cb, tries)
  tries = tries or 0
  if #vim.lsp.get_clients({ bufnr = bufnr }) > 0 then return cb(true) end
  if tries >= ATTACH_RETRIES or not vim.api.nvim_buf_is_valid(bufnr) then return cb(false) end
  vim.defer_fn(function() when_attached(bufnr, cb, tries + 1) end, 250)
end

---@param items table[] quickfix-style items
---@return string
local function format_items(items)
  local lines = {}
  for i, item in ipairs(items) do
    if i > MAX_ITEMS then
      table.insert(lines, fmt("… %d more results omitted", #items - MAX_ITEMS))
      break
    end
    local file = vim.fn.fnamemodify(item.filename or "", ":.")
    table.insert(lines, fmt("%s:%d:%d %s", file, item.lnum, item.col, vim.trim(item.text or "")))
  end
  return table.concat(lines, "\n")
end

---Merge results from every client that answered.
---@return table[] items, string|nil err
local function collect(results, to_items)
  local items, errs = {}, {}
  for client_id, res in pairs(results) do
    local client = vim.lsp.get_client_by_id(client_id)
    if res.err then
      table.insert(errs, res.err.message or tostring(res.err))
    elseif res.result and client then
      vim.list_extend(items, to_items(res.result, client.offset_encoding))
    end
  end
  return items, (#items == 0 and #errs > 0) and table.concat(errs, "; ") or nil
end

local function run(args, callback)
  local op = args.operation
  if not args.filepath or args.filepath == "" then
    return callback({ status = "error", data = "`filepath` is required" })
  end
  local bufnr, err = load_buffer(args.filepath)
  if not bufnr then return callback({ status = "error", data = err }) end

  when_attached(bufnr, function(attached)
    if not attached then
      return callback({
        status = "error",
        data = fmt("No language server attached to `%s`; use grep_search instead", args.filepath),
      })
    end

    local method, params, to_items
    local text_document = { uri = vim.uri_from_bufnr(bufnr) }

    if op == "document_symbols" then
      method = "textDocument/documentSymbol"
      params = { textDocument = text_document }
      to_items = function(result) return vim.lsp.util.symbols_to_items(result, bufnr) end
    elseif op == "workspace_symbols" then
      method = "workspace/symbol"
      params = { query = args.query or "" }
      to_items = function(result) return vim.lsp.util.symbols_to_items(result, bufnr) end
    elseif op == "definition" or op == "references" then
      if not args.line then return callback({ status = "error", data = fmt("`line` is required for `%s`", op) }) end
      local line = vim.api.nvim_buf_get_lines(bufnr, args.line - 1, args.line, false)[1]
      if not line then return callback({ status = "error", data = fmt("line %d is outside the file", args.line) }) end
      -- Default to the first non-blank column; convert the byte column to UTF-16 units.
      local byte_col = (args.column or (line:find("%S") or 1)) - 1
      local ok, character = pcall(vim.str_utfindex, line, "utf-16", math.min(byte_col, #line), false)
      method = op == "definition" and "textDocument/definition" or "textDocument/references"
      params = {
        textDocument = text_document,
        position = { line = args.line - 1, character = ok and character or byte_col },
        context = { includeDeclaration = true },
      }
      to_items = function(result, encoding)
        result = vim.islist(result) and result or { result }
        return vim.lsp.util.locations_to_items(result, encoding)
      end
    else
      return callback({ status = "error", data = fmt("unknown operation `%s`", tostring(op)) })
    end

    vim.lsp.buf_request_all(bufnr, method, params, function(results)
      local items, req_err = collect(results, to_items)
      if req_err then return callback({ status = "error", data = req_err }) end
      if #items == 0 then return callback({ status = "success", data = fmt("No results for %s", op) }) end
      callback({ status = "success", data = format_items(items) })
    end)
  end)
end

---@class CodeCompanion.Tool.LspSymbols: CodeCompanion.Tools.Tool
return {
  name = "lsp_symbols",
  cmds = {
    function(self, args, opts) run(args, vim.schedule_wrap(opts.output_cb)) end,
  },
  schema = {
    type = "function",
    ["function"] = {
      name = "lsp_symbols",
      description = "Navigate code semantically through the language server. Prefer this over text search when you need a symbol's definition, its usages, or an outline of a file or the project.",
      parameters = {
        type = "object",
        properties = {
          operation = {
            type = "string",
            enum = { "document_symbols", "workspace_symbols", "definition", "references" },
            description = "document_symbols: outline of `filepath`. workspace_symbols: find symbols project-wide matching `query` (`filepath` only selects which language server to ask). definition / references: for the symbol at `line` (and optionally `column`) in `filepath`.",
          },
          filepath = {
            type = "string",
            description = "Path of a source file. Its language server is the one queried.",
          },
          query = {
            type = "string",
            description = "Symbol name to search for. Only used by workspace_symbols.",
          },
          line = {
            type = "number",
            description = "1-based line of the symbol. Required for definition and references.",
          },
          column = {
            type = "number",
            description = "1-based byte column inside the symbol. Defaults to the first non-blank character of the line.",
          },
        },
        required = { "operation", "filepath" },
      },
    },
  },
  output = {
    cmd_string = function(self) return fmt("%s %s", self.args.operation, self.args.query or self.args.filepath) end,
    prompt = function(self)
      return fmt("Run LSP `%s` on `%s`?", self.args.operation, vim.fn.fnamemodify(self.args.filepath, ":."))
    end,
    success = function(self, stdout, meta)
      local output = vim.iter(stdout):flatten():join("\n")
      meta.tools.chat:add_tool_output(self, fmt("<lspSymbolsTool>\n%s\n</lspSymbolsTool>", output), "")
    end,
    error = function(self, stderr, meta)
      local errors = vim.iter(stderr):flatten():join("\n")
      log:debug("[LSP Symbols Tool] Error output: %s", stderr)
      meta.tools.chat:add_tool_output(self, errors)
    end,
  },
}
