local M = {}

local function count_aware_motion(default_motion, display_motion)
  return function()
    return vim.v.count == 0 and display_motion or default_motion
  end
end

function M.map_display_line_motion(buffer)
  local base = {
    buffer = buffer == nil and true or buffer,
    expr = true,
    nowait = true,
    silent = true,
  }

  vim.keymap.set(
    "n",
    "j",
    count_aware_motion("j", "gj"),
    vim.tbl_extend("force", base, {
      desc = "Move down display line",
    })
  )

  vim.keymap.set(
    "n",
    "k",
    count_aware_motion("k", "gk"),
    vim.tbl_extend("force", base, {
      desc = "Move up display line",
    })
  )
end

return M
