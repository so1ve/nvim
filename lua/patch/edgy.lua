-- Removes Edgy's clickable winbar toggle icon.
-- Purpose: keep edgebar titles visible while avoiding mouse-only close/toggle
-- affordances that are not part of the local UI model.
-- Behavior: preserve the EdgyTitle text, but omit the icon, click target, and
-- trailing tabline-click terminator from edgy.nvim's generated winbar.

local M = {}
local hacks = require("utils.hacks")

function M.patch()
  local window = require("edgy.window")

  hacks.replace(window, "edgy.window.winbar.without_button", "winbar", function(self)
    return "%<%#EdgyTitleAccent#▌%#EdgyTitle# " .. self.view.get_title() .. " %*"
  end)
end

function M.no_main()
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ group = "edgy_track", event = "WinClosed" })) do
    vim.api.nvim_del_autocmd(autocmd.id)
  end
end

return M
