local M = {}

function M.get(p)
  return {
    BlinkPairsRed = { fg = p.red },
    BlinkPairsYellow = { fg = p.yellow },
    BlinkPairsBlue = { fg = p.blue },
    BlinkPairsOrange = { fg = p.orange },
    BlinkPairsGreen = { fg = p.green },
    BlinkPairsMagenta = { fg = p.magenta },
    BlinkPairsCyan = { fg = p.cyan },
    BlinkPairsUnmatched = { fg = p.invalid },
  }
end

return M
