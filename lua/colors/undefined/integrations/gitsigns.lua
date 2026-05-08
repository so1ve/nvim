local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    GitSignsAdd = s.diff.add,
    GitSignsChange = s.diff.change,
    GitSignsDelete = s.diff.delete,
    GitSignsChangedelete = s.diff.change,
    GitSignsTopdelete = s.diff.delete,
    GitSignsUntracked = { fg = p.orange },
    GitSignsAddNr = s.diff.add,
    GitSignsChangeNr = s.diff.change,
    GitSignsDeleteNr = s.diff.delete,
    GitSignsChangedeleteNr = s.diff.change,
    GitSignsTopdeleteNr = s.diff.delete,
    GitSignsUntrackedNr = { fg = p.orange },
    GitSignsAddLn = s.diff.add_bg,
    GitSignsChangeLn = {},
    GitSignsChangedeleteLn = {},
    GitSignsTopdeleteLn = s.diff.delete_bg,
    GitSignsUntrackedLn = { bg = p.bg_alt },
    GitSignsAddCul = { fg = p.diff_add_fg, bg = p.bg_alt },
    GitSignsChangeCul = { fg = p.diff_change_fg, bg = p.bg_alt },
    GitSignsDeleteCul = { fg = p.diff_delete_fg, bg = p.bg_alt },
    GitSignsChangedeleteCul = { fg = p.diff_change_fg, bg = p.bg_alt },
    GitSignsTopdeleteCul = { fg = p.diff_delete_fg, bg = p.bg_alt },
    GitSignsUntrackedCul = { fg = p.orange, bg = p.bg_alt },
    GitSignsStagedAdd = { fg = p.green },
    GitSignsStagedChange = { fg = p.yellow },
    GitSignsStagedDelete = { fg = p.red },
    GitSignsStagedChangedelete = { fg = p.yellow },
    GitSignsStagedTopdelete = { fg = p.red },
    GitSignsStagedUntracked = { fg = p.orange },
    GitSignsAddPreview = s.diff.add_inline,
    GitSignsDeletePreview = s.diff.delete_inline,
    GitSignsNoEOLPreview = { fg = p.orange },
    GitSignsAddInline = s.diff.add_bg,
    GitSignsDeleteInline = s.diff.delete_bg,
    GitSignsChangeInline = {},
    GitSignsAddLnInline = s.diff.add_bg,
    GitSignsChangeLnInline = {},
    GitSignsDeleteLnInline = s.diff.delete_bg,
    GitSignsDeleteVirtLn = s.diff.delete_inline,
    GitSignsDeleteVirtLnInLine = s.diff.delete_inline,
    GitSignsVirtLnum = { fg = p.subtle },
    GitSignsCurrentLineBlame = { fg = p.subtle, italic = true },
  }
end

return M
