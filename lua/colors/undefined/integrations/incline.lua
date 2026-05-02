local M = {}

function M.get(p)
  return {
    InclineNormal = { fg = p.fg_dim, bg = p.bg_dark },
    InclineNormalNC = { fg = p.subtle, bg = p.bg_dark },
  }
end

return M
