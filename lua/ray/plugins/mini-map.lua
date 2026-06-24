local excluded_filetypes = {
  "bigfile",
  "gitcommit",
  "help",
  "markdown",
}
local windows = require("ray.utils.windows")

return {
  "mini.map",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  event = "UIEnter",
  keys = {
    {
      "<leader>um",
      function()
        require("mini.map").toggle()
      end,
      desc = "Toggle minimap",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = excluded_filetypes,
      callback = function(event)
        vim.b[event.buf].minimap_disable = true

        if _G.MiniMap ~= nil and event.buf == vim.api.nvim_get_current_buf() then
          MiniMap.close()
        end
      end,
    })
  end,
  config = function()
    local map = require("mini.map")

    map.setup({
      integrations = {
        map.gen_integration.builtin_search({ search = "MiniMapSearch" }),
        map.gen_integration.diagnostic({
          error = "MiniMapDiagnosticError",
          warn = "MiniMapDiagnosticWarn",
          info = "MiniMapDiagnosticInfo",
          hint = "MiniMapDiagnosticHint",
        }),
        map.gen_integration.diff({
          add = "MiniMapDiffAdd",
          change = "MiniMapDiffChange",
          delete = "MiniMapDiffDelete",
        }),
      },
      window = {
        zindex = 60,
      },
    })

    local gap = 20

    local function should_show_map()
      if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" or vim.b.minimap_disable then
        return false
      end

      local col = vim.api.nvim_win_get_cursor(0)[2]
      return vim.api.nvim_win_get_width(0) - col >= gap
    end

    local function update_map()
      if not windows.is_normal_win(vim.api.nvim_get_current_win()) then
        return
      end

      local should_show = should_show_map()
      if vim.w.ray_minimap_visible == should_show then
        return
      end

      vim.w.ray_minimap_visible = should_show
      if should_show then
        map.open()
      else
        map.close()
      end
    end

    vim.api.nvim_create_autocmd({ "BufWinEnter", "CursorMoved", "CursorMovedI" }, {
      callback = update_map,
    })

    update_map()
  end,
}
