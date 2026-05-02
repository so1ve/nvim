local M = {}

function M.get(p)
  return {
    TreesitterContext = { bg = p.bg_alt },
    TreesitterContextLineNumber = { fg = p.subtle, bg = p.bg_alt },
    TreesitterContextLineNumberBottom = { fg = p.fg_dim, bg = p.bg_alt, underline = true },
    TreesitterContextSeparator = { fg = p.border, bg = p.bg },
    TreesitterContextBottom = { sp = p.border, underline = true },
  }
end

return M
