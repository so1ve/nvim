local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    InclineNormal = s.statusline.section,
    InclineNormalNC = s.statusline.inactive,
  }
end

return M
