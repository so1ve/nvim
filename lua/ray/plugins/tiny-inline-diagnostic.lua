return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  keys = {
    { "<leader>di", "<cmd>TinyInlineDiag toggle<cr>", desc = "Toggle inline diagnostics" },
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
    local tiny_diag = require("tiny-inline-diagnostic")
    local renderer = require("tiny-inline-diagnostic.renderer")

    tiny_diag.setup(opts)

    vim.api.nvim_create_autocmd("WinScrolled", {
      callback = function(event)
        local winid = tonumber(event.match) or vim.api.nvim_get_current_win()
        local changes = vim.v.event and vim.v.event[tostring(winid)]

        if type(changes) == "table" and changes.topline == 0 and changes.leftcol == 0 and changes.skipcol == 0 then
          return
        end

        vim.schedule(function()
          vim.api.nvim_win_call(winid, function()
            local bufnr = vim.api.nvim_get_current_buf()
            renderer.safe_render(tiny_diag.config, bufnr)
            vim.api.nvim__redraw({ win = winid, valid = true, flush = false })
          end)
        end)
      end,
    })
  end,
}
