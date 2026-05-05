local M = {}

function M.patch()
  require("util.noice.hover_layout").patch()
  require("util.noice.hover_scroll").patch()
end

return M
