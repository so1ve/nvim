local M = {}

function M.patch()
  require("patch.noice.hover-layout").patch()
  require("patch.noice.hover-scroll").patch()
end

return M
