local M = {}

function M.get(p)
  return {
    NeoTreeNormal = { fg = p.fg, bg = p.bg },
    NeoTreeNormalNC = { fg = p.fg_dim, bg = p.bg },
    NeoTreeEndOfBuffer = { fg = p.bg, bg = p.bg },
    NeoTreeWinSeparator = { fg = p.border, bg = p.bg },
    NeoTreeFloatBorder = { fg = p.border, bg = p.bg },
    NeoTreeFloatTitle = { fg = p.green, bg = p.bg, bold = true },
    NeoTreeTitleBar = { fg = p.bg, bg = p.green, bold = true },
    NeoTreeCursorLine = { bg = p.bg_alt },
    NeoTreeDimText = { fg = p.subtle },
    NeoTreeMessage = { fg = p.fg_dim },
    NeoTreeExpander = { fg = p.subtle },
    NeoTreeIndentMarker = { fg = p.whitespace },
    NeoTreeRootName = { fg = p.green, bold = true },
    NeoTreeDirectoryName = { fg = p.green },
    NeoTreeDirectoryIcon = { fg = p.green },
    NeoTreeFileName = { fg = p.fg },
    NeoTreeFileNameOpened = { fg = p.fg, bold = true },
    NeoTreeFileIcon = { fg = p.blue },
    NeoTreeModified = { fg = p.orange },
    NeoTreeDotfile = { fg = p.subtle },
    NeoTreeHiddenByName = { fg = p.subtle },
    NeoTreeSymbolicLinkTarget = { fg = p.cyan },
    NeoTreeFilterTerm = { fg = p.orange, bold = true },
    NeoTreeGitAdded = { fg = p.diff_add_fg },
    NeoTreeGitDeleted = { fg = p.diff_delete_fg },
    NeoTreeGitModified = { fg = p.diff_change_fg },
    NeoTreeGitConflict = { fg = p.red, bold = true },
    NeoTreeGitUntracked = { fg = p.orange },
    NeoTreeGitIgnored = { fg = p.subtle },
    NeoTreeGitStaged = { fg = p.green },
    NeoTreeGitUnstaged = { fg = p.yellow },
    NeoTreeGitRenamed = { fg = p.blue },
    NeoTreeTabActive = { fg = p.fg, bg = p.bg_alt, bold = true },
    NeoTreeTabInactive = { fg = p.muted, bg = p.bg },
    NeoTreeTabSeparatorActive = { fg = p.border, bg = p.bg_alt },
    NeoTreeTabSeparatorInactive = { fg = p.border, bg = p.bg },
  }
end

return M
