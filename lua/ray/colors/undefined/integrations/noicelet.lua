local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    NoiceletFormatProgressDone = s.popup_editor.progress_done,
    NoiceletFormatProgressTodo = s.popup_editor.progress_todo,
    NoiceletLspMessageError = s.diagnostic.error,
    NoiceletLspMessageInfo = s.diagnostic.info,
    NoiceletLspMessageLog = { fg = p.muted },
    NoiceletLspMessageWarn = s.diagnostic.warn,
    NoiceletLspProgressClient = { fg = p.muted },
    NoiceletLspProgressSpinner = { fg = p.cyan },
    NoiceletLspProgressTitle = { fg = p.fg },
    NoiceletMini = { fg = p.fg_dim },
  }
end

return M
