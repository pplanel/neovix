-- Snacks highlights for kanagawa.nvim, taken from the author's PR
-- (lua/kanagawa/highlights/plugins.lua). kanagawa-nvim comes from the read-only
-- Nix store, so theme.lua feeds this table to its `overrides`.
local M = {}

---@param colors KanagawaColors
function M.setup(colors)
  local theme = colors.theme
  return {
    -- SnacksDashboard
    SnacksDashboardHeader = { fg = theme.vcs.removed },
    SnacksDashboardFooter = { fg = theme.syn.comment },
    SnacksDashboardDesc = { fg = theme.syn.identifier },
    SnacksDashboardIcon = { fg = theme.ui.special },
    SnacksDashboardKey = { fg = theme.syn.special1 },
    SnacksDashboardSpecial = { fg = theme.syn.comment },
    SnacksDashboardDir = { fg = theme.syn.identifier },
    -- SnacksNotifier
    SnacksNotifierBorderError = { link = "DiagnosticError" },
    SnacksNotifierBorderWarn = { link = "DiagnosticWarn" },
    SnacksNotifierBorderInfo = { link = "DiagnosticInfo" },
    SnacksNotifierBorderDebug = { link = "Debug" },
    SnacksNotifierBorderTrace = { link = "Comment" },
    SnacksNotifierIconError = { link = "DiagnosticError" },
    SnacksNotifierIconWarn = { link = "DiagnosticWarn" },
    SnacksNotifierIconInfo = { link = "DiagnosticInfo" },
    SnacksNotifierIconDebug = { link = "Debug" },
    SnacksNotifierIconTrace = { link = "Comment" },
    SnacksNotifierTitleError = { link = "DiagnosticError" },
    SnacksNotifierTitleWarn = { link = "DiagnosticWarn" },
    SnacksNotifierTitleInfo = { link = "DiagnosticInfo" },
    SnacksNotifierTitleDebug = { link = "Debug" },
    SnacksNotifierTitleTrace = { link = "Comment" },
    SnacksNotifierError = { link = "DiagnosticError" },
    SnacksNotifierWarn = { link = "DiagnosticWarn" },
    SnacksNotifierInfo = { link = "DiagnosticInfo" },
    SnacksNotifierDebug = { link = "Debug" },
    SnacksNotifierTrace = { link = "Comment" },
    -- SnacksProfiler
    SnacksProfilerIconInfo = { bg = theme.ui.bg_search, fg = theme.syn.fun },
    SnacksProfilerBadgeInfo = { bg = theme.ui.bg_visual, fg = theme.syn.fun },
    SnacksScratchKey = { link = "SnacksProfilerIconInfo" },
    SnacksScratchDesc = { link = "SnacksProfilerBadgeInfo" },
    SnacksProfilerIconTrace = { bg = theme.syn.fun, fg = theme.ui.float.fg_border },
    SnacksProfilerBadgeTrace = { bg = theme.syn.fun, fg = theme.ui.float.fg_border },
    SnacksIndent = { fg = theme.ui.bg_p2, nocombine = true },
    SnacksIndentScope = { fg = theme.ui.pmenu.bg, nocombine = true },
    SnacksZenIcon = { fg = theme.syn.statement },
    SnacksInputIcon = { fg = theme.ui.pmenu.bg },
    SnacksInputBorder = { fg = theme.syn.identifier },
    SnacksInputTitle = { fg = theme.syn.identifier },
    -- SnacksPicker
    SnacksPickerInputBorder = { fg = theme.syn.constant },
    SnacksPickerInputTitle = { fg = theme.syn.constant },
    SnacksPickerBoxTitle = { fg = theme.syn.constant },
    SnacksPickerSelected = { fg = theme.syn.number },
    SnacksPickerToggle = { link = "SnacksProfilerBadgeInfo" },
    SnacksPickerPickWinCurrent = { fg = theme.ui.fg, bg = theme.syn.number, bold = true },
    SnacksPickerPickWin = { fg = theme.ui.fg, bg = theme.ui.bg_search, bold = true },
  }
end

return M
