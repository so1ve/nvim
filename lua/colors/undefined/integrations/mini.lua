local M = {}

function M.get(p)
  return {
    MiniStatuslineModeNormal = { fg = p.bg_dark, bg = p.green, bold = true },
    MiniStatuslineModeInsert = { fg = p.bg_dark, bg = p.blue, bold = true },
    MiniStatuslineModeVisual = { fg = p.bg_dark, bg = p.magenta, bold = true },
    MiniStatuslineModeReplace = { fg = p.bg_dark, bg = p.red, bold = true },
    MiniStatuslineModeCommand = { fg = p.bg_dark, bg = p.yellow, bold = true },
    MiniStatuslineModeOther = { fg = p.bg_dark, bg = p.cyan, bold = true },
    MiniStatuslineDevinfo = { fg = p.fg_dim, bg = p.bg_dark },
    MiniStatuslineFileinfo = { fg = p.fg_dim, bg = p.bg_dark },
    MiniStatuslineInactive = { fg = p.subtle, bg = p.bg_dark },
    MiniHipatternsFixme = { fg = p.bg, bg = p.red, bold = true },
    MiniHipatternsHack = { fg = p.bg, bg = p.orange, bold = true },
    MiniHipatternsNote = { fg = p.bg, bg = p.blue, bold = true },
    MiniHipatternsTodo = { fg = p.bg, bg = p.yellow, bold = true },
    MiniIconsAzure = { fg = p.blue },
    MiniIconsBlue = { fg = p.blue },
    MiniIconsCyan = { fg = p.cyan },
    MiniIconsGreen = { fg = p.green },
    MiniIconsGrey = { fg = p.muted },
    MiniIconsOrange = { fg = p.orange },
    MiniIconsPurple = { fg = p.magenta },
    MiniIconsRed = { fg = p.red },
    MiniIconsYellow = { fg = p.yellow },
  }
end

return M
