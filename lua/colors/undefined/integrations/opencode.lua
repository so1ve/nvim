local M = {}

function M.get(p)
  return {
    OpencodeContextPlaceholder = { fg = p.muted, italic = true },
    OpencodeContextValue = { fg = p.string },
    OpencodeAgent = { fg = p.property, bold = true },
  }
end

return M
