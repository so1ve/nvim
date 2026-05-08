local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    MiniStatuslineModeNormal = s.statusline.mode(p.green),
    MiniStatuslineModeInsert = s.statusline.mode(p.blue),
    MiniStatuslineModeVisual = s.statusline.mode(p.magenta),
    MiniStatuslineModeReplace = s.statusline.mode(p.red),
    MiniStatuslineModeCommand = s.statusline.mode(p.yellow),
    MiniStatuslineModeOther = s.statusline.mode(p.cyan),
    MiniStatuslineDevinfo = s.statusline.section,
    MiniStatuslineFileinfo = s.statusline.section,
    MiniStatuslineInactive = s.statusline.inactive,
    MiniTablineCurrent = s.tabline.current,
    MiniTablineVisible = s.tabline.visible,
    MiniTablineHidden = s.tabline.hidden,
    MiniTablineModifiedCurrent = styles.extend(s.tabline.current, { fg = p.orange, italic = true }),
    MiniTablineModifiedVisible = styles.extend(s.tabline.visible, { fg = p.orange, italic = true }),
    MiniTablineModifiedHidden = styles.extend(s.tabline.hidden, { italic = true }),
    MiniTablineFill = s.tabline.fill,
    MiniTablineTabpagesection = s.statusline.mode(p.green),
    MiniTablineTrunc = s.tabline.trunc,
    MiniClueBorder = s.float.border,
    MiniClueDescGroup = s.title,
    MiniClueDescSingle = s.dim,
    MiniClueNextKey = s.key,
    MiniClueNextKeyWithPostkeys = { fg = p.yellow, bold = true },
    MiniClueSeparator = s.separator,
    MiniClueTitle = s.title,
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
