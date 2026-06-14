local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    NeoTreeNormal = s.normal,
    NeoTreeNormalNC = s.normal_nc,
    NeoTreeEndOfBuffer = { fg = p.bg, bg = p.bg },
    NeoTreeWinSeparator = s.float.separator,
    NeoTreeFloatBorder = s.float.border,
    NeoTreeFloatTitle = s.float.title,
    NeoTreeTitleBar = styles.extend(s.statusline.mode(p.green), { bold = true }),
    NeoTreeCursorLine = { bg = p.bg_alt },
    NeoTreeDimText = s.subtle,
    NeoTreeMessage = s.dim,
    NeoTreeExpander = s.subtle,
    NeoTreeIndentMarker = { fg = p.whitespace },
    NeoTreeRootName = s.title,
    NeoTreeDirectoryName = { fg = p.green },
    NeoTreeDirectoryIcon = { fg = p.green },
    NeoTreeFileName = { fg = p.fg },
    NeoTreeFileNameOpened = { fg = p.fg, bold = true },
    NeoTreeFileIcon = { fg = p.green },
    NeoTreeModified = { fg = p.orange },
    NeoTreeDotfile = s.subtle,
    NeoTreeHiddenByName = s.subtle,
    NeoTreeSymbolicLinkTarget = { fg = p.cyan },
    NeoTreeFilterTerm = s.match,
    NeoTreeGitAdded = s.diff.add,
    NeoTreeGitDeleted = s.diff.delete,
    NeoTreeGitModified = s.diff.change,
    NeoTreeGitConflict = { fg = p.red, bold = true },
    NeoTreeGitUntracked = { fg = p.orange },
    NeoTreeGitIgnored = s.subtle,
    NeoTreeGitStaged = { fg = p.green },
    NeoTreeGitUnstaged = { fg = p.yellow },
    NeoTreeGitRenamed = { fg = p.cyan },
    NeoTreeTabActive = s.tabline.current,
    NeoTreeTabInactive = { fg = p.muted, bg = p.bg },
    NeoTreeTabSeparatorActive = { fg = p.border, bg = p.bg_alt },
    NeoTreeTabSeparatorInactive = { fg = p.border, bg = p.bg },
  }
end

return M
