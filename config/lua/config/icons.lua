-- Nerd Font glyphs, written as codepoint escapes so the source stays plain
-- ASCII and survives any editor, pager or tool that mangles private-use chars.
local M = {}

M.diagnostics = {
  Error = "\u{f057} ",
  Warn = "\u{f071} ",
  Hint = "\u{f0eb} ",
  Info = "\u{f05a} ",
}

M.dap = {
  Stopped = "\u{f0055} ",
  Breakpoint = "\u{f111} ",
  BreakpointCondition = "\u{f059} ",
  BreakpointRejected = "\u{f06a} ",
  LogPoint = ".>",
}

M.git = {
  added = "\u{258e}", -- ▎
  changed = "\u{258e}",
  deleted = "\u{f0da}",
}

M.ui = {
  chevron_down = "\u{f47c}",
  chevron_right = "\u{f460}",
  lock = "\u{f023}",
  gear = "\u{f013}",
  bolt = "\u{f0e7}",
  sep_left = "\u{e0b6}",
  sep_right = "\u{e0b4}",
}

M.telescope = {
  prompt = "\u{f002}  ", -- magnifier
  caret = "\u{f0da} ", -- caret right
  multi = "\u{f00c} ", -- check
}

M.dashboard = {
  find = "\u{f002} ",
  new = "\u{f15b} ",
  grep = "\u{f0b0} ",
  recent = "\u{f1da} ",
  config = "\u{f013} ",
  session = "\u{f021} ",
  quit = "\u{f426} ",
}

return M
