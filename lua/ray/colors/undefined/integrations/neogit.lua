local M = {}

function M.get(p)
  return {
    NeogitDiffHeader = { fg = p.diff_header, bg = p.bg, bold = true },
    NeogitDiffHeaderHighlight = { fg = p.diff_header, bg = p.bg, bold = true },
    NeogitDiffHeaderCursor = { fg = p.diff_header, bg = p.bg, bold = true },
    NeogitDiffContext = { bg = p.bg },
    NeogitDiffContextHighlight = { bg = p.bg },
    NeogitDiffContextCursor = { bg = p.bg },
    NeogitDiffAdd = { fg = p.diff_add_fg, bg = p.diff_add_bg },
    NeogitDiffAddHighlight = { fg = p.diff_add_fg, bg = p.diff_add_bg },
    NeogitDiffAddCursor = { fg = p.diff_add_fg, bg = p.diff_add_bg },
    NeogitDiffDelete = { fg = p.diff_delete_fg, bg = p.diff_delete_bg },
    NeogitDiffDeleteHighlight = { fg = p.diff_delete_fg, bg = p.diff_delete_bg },
    NeogitDiffDeleteCursor = { fg = p.diff_delete_fg, bg = p.diff_delete_bg },
    NeogitHunkHeader = { fg = p.diff_header, bg = p.bg, bold = true },
    NeogitHunkHeaderHighlight = { fg = p.diff_header, bg = p.bg, bold = true },
    NeogitHunkHeaderCursor = { fg = p.diff_header, bg = p.bg, bold = true },
  }
end

return M
