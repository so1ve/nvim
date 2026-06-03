local M = {}

function M.get(p)
  return {
    FFFPreviewCurrentMatch = { fg = p.bg, bg = p.yellow, bold = true },
  }
end

return M
