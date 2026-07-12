local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    TreesitterContext = { bg = p.bg_alt },
    TreesitterContextLineNumber = { fg = p.subtle, bg = p.bg_alt },
    TreesitterContextLineNumberBottom = { fg = p.fg_dim, bg = p.bg_alt, underline = true },
    TreesitterContextSeparator = { fg = s.float.separator.fg, bg = p.bg_alt },
  }
end

return M
