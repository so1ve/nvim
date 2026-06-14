local M = {}

function M.get(p)
  return {
    EdgyTitle = { fg = p.green, bg = p.bg, bold = true },
    EdgyWinBar = { fg = p.subtle, bg = p.bg },
    EdgyWinBarNC = { fg = p.subtle, bg = p.bg },
  }
end

return M
