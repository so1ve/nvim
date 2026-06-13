local M = {}

function M.get(p)
  return {
    EdgyTitleAccent = { fg = p.green, bg = p.bg },
    EdgyTitle = { fg = p.fg_dim, bg = p.bg, bold = true },
    EdgyWinBar = { fg = p.subtle, bg = p.bg },
    EdgyWinBarNC = { fg = p.subtle, bg = p.bg },
  }
end

return M
