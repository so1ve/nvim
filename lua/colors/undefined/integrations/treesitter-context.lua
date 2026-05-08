local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    TreesitterContext = { bg = p.bg_alt },
    TreesitterContextLineNumber = { fg = p.subtle, bg = p.bg_alt },
    TreesitterContextLineNumberBottom = { fg = p.fg_dim, bg = p.bg_alt, underline = true },
    TreesitterContextSeparator = s.float.separator,
    TreesitterContextBottom = { sp = p.border, underline = true },
  }
end

return M
