return {
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  cmd = "Neominimap",
  event = "VeryLazy",
  init = function()
    vim.g.neominimap = {
      exclude_filetypes = {
        "help",
        "bigfile",
        "markdown",
        "gitcommit",
      },
      win_filter = function(winid)
        return not vim.w[winid].codediff_restore
      end,
    }
  end,
}
