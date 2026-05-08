local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    NoiceCmdline = { fg = p.fg, bg = p.bg_dark },
    NoiceCmdlineIcon = { fg = p.blue },
    NoiceCmdlineIconSearch = { fg = p.yellow },
    NoiceCmdlinePrompt = s.title,
    NoiceCmdlinePopup = s.popup.normal,
    NoiceCmdlinePopupBorder = s.popup.border,
    NoiceCmdlinePopupTitle = s.popup.title,
    NoiceCmdlinePopupBorderSearch = s.popup.border_search,
    NoiceConfirm = s.popup.normal,
    NoiceConfirmBorder = s.popup.border,
    NoiceCursor = { fg = p.bg, bg = p.fg },
    NoiceMini = { fg = p.fg_dim, bg = p.bg_dark },
    NoicePopup = s.float.normal,
    NoicePopupBorder = s.float.border,
    NoicePopupmenu = s.popup.normal,
    NoicePopupmenuMatch = s.match,
    NoicePopupmenuSelected = s.popup.selected,
    NoiceSplit = s.float.normal,
    NoiceVirtualText = { fg = p.blue },
    NoiceFormatProgressDone = s.popup.progress_done,
    NoiceFormatProgressTodo = s.popup.progress_todo,
    NoiceFormatEvent = { fg = p.magenta },
    NoiceFormatKind = { fg = p.orange },
    NoiceFormatDate = { fg = p.muted },
    NoiceFormatConfirm = { fg = p.green },
    NoiceFormatConfirmDefault = s.title,
    NoiceFormatTitle = s.title,
    NoiceFormatLevelDebug = s.diagnostic.debug,
    NoiceFormatLevelTrace = s.diagnostic.trace,
    NoiceFormatLevelOff = { fg = p.subtle },
    NoiceFormatLevelInfo = s.diagnostic.info,
    NoiceFormatLevelWarn = s.diagnostic.warn,
    NoiceFormatLevelError = s.message.error,
    NoiceLspProgressSpinner = { fg = p.cyan },
    NoiceLspProgressTitle = { fg = p.fg },
    NoiceLspProgressClient = { fg = p.muted },
    NoiceHiddenCursor = { blend = 100, nocombine = true },
  }
end

return M
