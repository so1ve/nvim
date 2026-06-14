local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)
  local context_blend = vim.g.neovide and 24 or nil

  return {
    TreesitterContext = { bg = p.bg_alt, blend = context_blend },
    TreesitterContextLineNumber = { fg = p.subtle, bg = p.bg_alt, blend = context_blend },
    TreesitterContextLineNumberBottom = { fg = p.fg_dim, bg = p.bg_alt, underline = true, blend = context_blend },
    TreesitterContextSeparator = { fg = s.float.separator.fg, bg = p.bg_alt, blend = context_blend },
    TreesitterContextBottom = { sp = p.border, underline = true, blend = context_blend },
  }
end

return M
