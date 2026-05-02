local M = {}

function M.get(p)
  return {
    SidekickSign = { fg = p.green, bg = p.bg },
    SidekickDiffContext = { bg = p.bg },
    SidekickDiffAdd = { fg = p.green },
    SidekickDiffDelete = { fg = p.red, bg = "#342828" },
  }
end

return M
