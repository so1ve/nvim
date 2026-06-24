local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    NeominimapBackground = s.float.normal,
    NeominimapBorder = s.float.border,
    NeominimapCursorLine = { bg = p.selection },
    NeominimapCursorLineNr = { fg = p.green, bg = p.selection, bold = true },
    NeominimapCursorLineSign = { fg = p.green, bg = p.selection },
    NeominimapCursorLineFold = { fg = p.green, bg = p.selection },

    NeominimapHintLine = { fg = p.green },
    NeominimapInfoLine = { fg = p.blue },
    NeominimapWarnLine = { fg = p.orange },
    NeominimapErrorLine = { fg = p.red },
    NeominimapHintSign = s.diagnostic.hint,
    NeominimapInfoSign = s.diagnostic.info,
    NeominimapWarnSign = s.diagnostic.warn,
    NeominimapErrorSign = s.diagnostic.error,
    NeominimapHintIcon = s.diagnostic.hint,
    NeominimapInfoIcon = s.diagnostic.info,
    NeominimapWarnIcon = s.diagnostic.warn,
    NeominimapErrorIcon = s.diagnostic.error,

    NeominimapGitAddLine = s.diff.add,
    NeominimapGitChangeLine = s.diff.change,
    NeominimapGitDeleteLine = s.diff.delete,
    NeominimapGitAddSign = s.diff.add,
    NeominimapGitChangeSign = s.diff.change,
    NeominimapGitDeleteSign = s.diff.delete,
    NeominimapGitAddIcon = s.diff.add,
    NeominimapGitChangeIcon = s.diff.change,
    NeominimapGitDeleteIcon = s.diff.delete,

    NeominimapMiniDiffAddLine = s.diff.add,
    NeominimapMiniDiffChangeLine = s.diff.change,
    NeominimapMiniDiffDeleteLine = s.diff.delete,
    NeominimapMiniDiffAddSign = s.diff.add,
    NeominimapMiniDiffChangeSign = s.diff.change,
    NeominimapMiniDiffDeleteSign = s.diff.delete,
    NeominimapMiniDiffAddIcon = s.diff.add,
    NeominimapMiniDiffChangeIcon = s.diff.change,
    NeominimapMiniDiffDeleteIcon = s.diff.delete,

    NeominimapSearchLine = { fg = p.orange, bold = true },
    NeominimapSearchSign = { fg = p.orange, bold = true },
    NeominimapSearchIcon = { fg = p.orange, bold = true },
  }
end

return M
