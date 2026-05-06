local M = {}

function M.patch()
  require("utils.noice.hover_layout").patch()
  require("utils.noice.hover_scroll").patch()
end

return M
