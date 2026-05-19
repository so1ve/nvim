local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  local groups = {
    MiniStatuslineModeNormal = s.statusline.mode(p.green),
    MiniStatuslineModeInsert = s.statusline.mode(p.blue),
    MiniStatuslineModeVisual = s.statusline.mode(p.magenta),
    MiniStatuslineModeReplace = s.statusline.mode(p.red),
    MiniStatuslineModeCommand = s.statusline.mode(p.yellow),
    MiniStatuslineModeOther = s.statusline.mode(p.cyan),
    MiniStatuslineDevinfo = s.statusline.section,
    MiniStatuslinePath = s.statusline.section,
    MiniStatuslineInputState = s.statusline.section,
    MiniStatuslineMetadata = s.statusline.section,
    MiniStatuslineDirectory = { fg = p.comment, bg = p.bg_dark },
    MiniStatuslineFilename = { fg = p.fg, bg = p.bg_dark },
    MiniStatuslineInactive = s.statusline.inactive,
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

  local icon_colors = {
    Azure = p.blue,
    Blue = p.blue,
    Cyan = p.cyan,
    Green = p.green,
    Grey = p.muted,
    Orange = p.orange,
    Purple = p.magenta,
    Red = p.red,
    Yellow = p.yellow,
  }

  for name, color in pairs(icon_colors) do
    groups["MiniTablineIcon" .. name .. "Current"] = { fg = color, bg = p.bg_alt }
    groups["MiniTablineIcon" .. name .. "Inactive"] = { fg = color, bg = p.bg_dark }
  end

  return groups
end

return M
