local symbols = require("ray.config.symbols")

local function panel(id, opener)
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
        filter = symbols.trouble_lsp_symbol_filter,
      },
    },
  },
  keys = {
    {
      "<leader>xd",
      panel("trouble.problems", "Trouble diagnostics toggle filter.buf=0"),
      desc = "Buffer diagnostics",
    },
    {
      "<leader>xD",
      panel("trouble.problems", "Trouble diagnostics toggle"),
      desc = "Workspace diagnostics",
    },
    {
      "<leader>xs",
      panel("trouble.lsp", "Trouble symbols toggle"),
      desc = "Symbols",
    },
    {
      "<leader>xl",
      panel("trouble.problems", "Trouble loclist toggle"),
      desc = "Location list",
    },
    {
      "<leader>xq",
      panel("trouble.problems", "Trouble qflist toggle"),
      desc = "Quickfix list",
    },
  },
}
