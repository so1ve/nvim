local M = {}

function M.get(p)
  return {
    NeogitHunkHeader = { fg = p.diff_header, bg = p.bg_alt, bold = true },
    NeogitHunkHeaderHighlight = { fg = p.diff_header, bg = p.inactive_selection, bold = true },
    NeogitHunkHeaderCursor = { fg = p.diff_header, bg = p.selection, bold = true },
  }
end

return M
