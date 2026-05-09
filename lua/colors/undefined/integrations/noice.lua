local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    NoiceCmdline = { fg = p.fg, bg = p.bg_dark },
    NoiceCmdlineIcon = { fg = p.green },
    NoiceCmdlineIconSearch = { fg = p.yellow },
    NoiceCmdlinePrompt = s.input.prompt,
    NoiceCmdlinePopup = s.popup_editor.normal,
    NoiceCmdlinePopupBorder = s.popup_editor.border,
    NoiceCmdlinePopupTitle = s.popup_editor.title,
    NoiceCmdlinePopupBorderSearch = s.popup_editor.border_search,
    NoiceConfirm = s.popup_editor.normal,
    NoiceConfirmBorder = s.popup_editor.border,
    NoiceCursor = { fg = p.bg, bg = p.fg },
    NoiceMini = { fg = p.fg_dim, bg = p.bg_dark },
    NoicePopup = s.float.normal,
    NoicePopupBorder = s.float.border,
    NoicePopupmenu = s.popup_editor.normal,
    NoicePopupmenuMatch = s.match,
    NoicePopupmenuSelected = s.popup.selected,
    NoiceSplit = s.float.normal,
    NoiceVirtualText = { fg = p.green },
    NoiceFormatProgressDone = s.popup_editor.progress_done,
    NoiceFormatProgressTodo = s.popup_editor.progress_todo,
    NoiceFormatEvent = { fg = p.magenta },
    NoiceFormatKind = { fg = p.orange },
    NoiceFormatDate = { fg = p.muted },
    NoiceFormatConfirm = { fg = p.green },
    NoiceFormatConfirmDefault = s.title,
    NoiceFormatTitle = s.title,
    NoiceFormatLevelOff = { fg = p.subtle },
    NoiceFormatLevelTrace = s.diagnostic.trace,
    NoiceFormatLevelDebug = s.diagnostic.debug,
    NoiceFormatLevelInfo = s.diagnostic.info,
    NoiceFormatLevelWarn = s.diagnostic.warn,
    NoiceFormatLevelError = s.diagnostic.error,
    NoiceLspProgressSpinner = { fg = p.cyan },
    NoiceLspProgressTitle = { fg = p.fg },
    NoiceLspProgressClient = { fg = p.muted },
    NoiceHiddenCursor = { blend = 100, nocombine = true },
  }
end

return M
