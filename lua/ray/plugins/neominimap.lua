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
      float = {
        z_index = 25,
      },
      win_filter = function(winid)
        return not vim.w[winid].codediff_restore
      end,
    }
  end,
  config = function()
    local neominimap = require("neominimap.api")
    local gap = 20

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      callback = function()
        if vim.bo.filetype == "neominimap" then
          return
        end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        local should_hide = vim.api.nvim_win_get_width(0) - col < gap
        if (vim.w.ray_neominimap_hidden == true) == should_hide then
          return
        end

        vim.w.ray_neominimap_hidden = should_hide
        if should_hide then
          neominimap.win.disable()
        else
          neominimap.win.enable()
        end
      end,
    })
  end,
}
