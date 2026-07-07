local symbols = require("ray.config.symbols")

local function open_panel(id, opener)
  return function()
    require("panels").open(id, opener)
  end
end

return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {
    modes = {
      symbols = {
        filter = symbols.trouble_lsp_symbol_filter(),
      },
    },
  },
  keys = {
    {
      "<leader>xd",
      open_panel("trouble.problems", "Trouble diagnostics toggle filter.buf=0"),
      desc = "Buffer diagnostics",
    },
    {
      "<leader>xD",
      open_panel("trouble.problems", "Trouble diagnostics toggle"),
      desc = "Workspace diagnostics",
    },
    {
      "<leader>xs",
      open_panel("trouble.lsp", "Trouble symbols toggle"),
      desc = "Symbols",
    },
    {
      "<leader>xl",
      open_panel("trouble.lsp", "Trouble lsp toggle win.position=right"),
      desc = "LSP definitions/references",
    },
    {
      "<leader>xL",
      open_panel("trouble.problems", "Trouble loclist toggle"),
      desc = "Location list",
    },
    {
      "<leader>xQ",
      open_panel("trouble.problems", "Trouble qflist toggle"),
      desc = "Quickfix list",
    },
  },
}
