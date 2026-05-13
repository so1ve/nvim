local M = {}

function M.get(p)
  return {
    RainbowDelimiterRed = { fg = p.red },
    RainbowDelimiterYellow = { fg = p.yellow },
    RainbowDelimiterBlue = { fg = p.blue },
    RainbowDelimiterOrange = { fg = p.orange },
    RainbowDelimiterGreen = { fg = p.green },
    RainbowDelimiterViolet = { fg = p.magenta },
    RainbowDelimiterCyan = { fg = p.cyan },
  }
end

return M
