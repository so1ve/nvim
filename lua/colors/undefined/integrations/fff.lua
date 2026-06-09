local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    FFFPreviewCurrentMatch = s.search,
  }
end

return M
