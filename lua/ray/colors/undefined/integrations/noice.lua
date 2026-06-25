local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    NoiceConfirm = s.popup_editor.normal,
    NoiceConfirmBorder = s.popup_editor.border,
    NoiceMini = { fg = p.fg_dim, bg = p.bg_dark },
    NoicePopup = s.float.normal,
    NoicePopupBorder = s.float.border,
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
  }
end

return M
