local M = {}

function M.get(p)
  return {
    SatelliteBackground = { bg = p.bg },
    SatelliteBar = { bg = p.selection },
    SatelliteCursor = { fg = p.fg_dim },
    SatelliteDiagnosticError = { fg = p.red },
    SatelliteDiagnosticHint = { fg = p.green },
    SatelliteDiagnosticInfo = { fg = p.blue },
    SatelliteDiagnosticWarn = { fg = p.orange },
    SatelliteGitSignsAdd = { fg = p.diff_add_fg },
    SatelliteGitSignsChange = { fg = p.diff_change_fg },
    SatelliteGitSignsDelete = { fg = p.diff_delete_fg },
    SatelliteMark = { fg = p.magenta },
    SatelliteQuickfix = { fg = p.yellow },
    SatelliteSearch = { fg = p.yellow },
    SatelliteSearchCurrent = { fg = p.orange },
  }
end

return M
