local M = {}

function M.refresh()
  pcall(function()
    require("satellite.view").schedule_refresh()
  end)
end

return M
