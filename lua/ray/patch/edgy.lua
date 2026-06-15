-- Removes Edgy's clickable winbar toggle icon.
-- Purpose: keep edgebar titles visible while avoiding mouse-only close/toggle
-- affordances that are not part of the local UI model.
-- Behavior: preserve the EdgyTitle text, but omit the icon, click target, and
-- trailing tabline-click terminator from edgy.nvim's generated winbar.

local M = {}
local hacks = require("ray.utils.hacks")

function M.patch()
  local window = require("edgy.window")

  hacks.replace(window, "edgy.window.winbar.without_button", "winbar", function(self)
    return "%<%#EdgyTitle#" .. self.view.get_title() .. "%*"
  end)
end

return M
