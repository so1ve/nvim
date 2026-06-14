local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    SidekickSign = { fg = p.green, bg = p.bg },
    SidekickDiffContext = {},
    SidekickDiffAdd = s.diff.add_bg,
    SidekickDiffDelete = s.diff.delete_bg,
  }
end

return M
