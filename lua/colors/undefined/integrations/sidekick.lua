local M = {}

function M.get(p)
  return {
    SidekickSign = { fg = p.green, bg = p.bg },
    SidekickDiffContext = {},
    SidekickDiffAdd = { bg = p.diff_add_bg },
    SidekickDiffDelete = { bg = p.diff_delete_bg },
  }
end

return M
