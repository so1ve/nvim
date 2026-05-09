local function refresh_visible_diagnostics(winid)
  if not vim.api.nvim_win_is_valid(winid) then
    return
  end

  vim.api.nvim_win_call(winid, function()
    local tiny_diag = require("tiny-inline-diagnostic")

    if not tiny_diag.config then
      return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    require("tiny-inline-diagnostic.renderer").safe_render(tiny_diag.config, bufnr)

    if vim.api.nvim__redraw then
      vim.api.nvim__redraw({ win = winid, valid = true, flush = false })
    end
  end)
end

local function register_scroll_refresh_autocmd()
  local group = vim.api.nvim_create_augroup("RayTinyInlineDiagnosticScrollRefresh", { clear = true })

  vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = function(event)
      local winid = tonumber(event.match) or vim.api.nvim_get_current_win()
      local changes = vim.v.event and vim.v.event[tostring(winid)]

      if type(changes) == "table" and changes.topline == 0 and changes.leftcol == 0 and changes.skipcol == 0 then
        return
      end

      vim.schedule(function()
        refresh_visible_diagnostics(winid)
      end)
    end,
    desc = "Refresh tiny inline diagnostics after scrolling",
  })
end

return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  keys = {
    { "<leader>di", "<cmd>TinyInlineDiag toggle_cursor_only<cr>", desc = "Toggle cursor-only diagnostics" },
    { "<leader>dI", "<cmd>TinyInlineDiag toggle<cr>", desc = "Toggle inline diagnostics" },
  },
  opts = {
    hi = {
      background = "Normal",
    },
    options = {
      show_source = { enabled = true, if_many = true },
      throttle = 0,
      multilines = { enabled = true },
      override_open_float = true,
    },
  },
  config = function(_, opts)
    require("tiny-inline-diagnostic").setup(opts)
    register_scroll_refresh_autocmd()
  end,
}
