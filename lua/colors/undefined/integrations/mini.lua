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
    MiniStatuslineDiffAdd = { fg = p.diff_add_fg, bg = p.bg_dark },
    MiniStatuslineDiffChange = { fg = p.diff_change_fg, bg = p.bg_dark },
    MiniStatuslineDiffDelete = { fg = p.diff_delete_fg, bg = p.bg_dark },
    MiniHipatternsFixme = { fg = p.bg, bg = p.red, bold = true },
    MiniHipatternsHack = { fg = p.bg, bg = p.orange, bold = true },
    MiniHipatternsNote = { fg = p.bg, bg = p.green, bold = true },
    MiniHipatternsPerf = { fg = p.bg, bg = p.magenta, bold = true },
    MiniHipatternsTest = { fg = p.bg, bg = p.magenta, bold = true },
    MiniHipatternsTodo = { fg = p.bg, bg = p.blue, bold = true },
    MiniHipatternsWarn = { fg = p.bg, bg = p.orange, bold = true },
    MiniDiffSignAdd = s.diff.add,
    MiniDiffSignChange = s.diff.change,
    MiniDiffSignDelete = s.diff.delete,
    MiniDiffOverAdd = s.diff.add_bg,
    MiniDiffOverChange = { fg = p.diff_change_fg, bg = p.bg_alt },
    MiniDiffOverChangeBuf = { bg = p.bg_alt },
    MiniDiffOverContext = { fg = p.subtle, bg = p.bg_alt },
    MiniDiffOverContextBuf = {},
    MiniDiffOverDelete = s.diff.delete_inline,
    MiniJump = { fg = p.bg, bg = p.yellow, bold = true },
    MiniJump2dSpot = { fg = p.bg, bg = p.yellow, bold = true, nocombine = true },
    MiniJump2dSpotUnique = { fg = p.bg, bg = p.yellow, bold = true, nocombine = true },
    MiniJump2dSpotAhead = { fg = p.bg, bg = p.orange, nocombine = true },
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
