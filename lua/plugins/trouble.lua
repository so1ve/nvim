local edgy = require("integrations.edgy")
local symbols = require("config.symbols")

local function trouble_filter(position)
  return function(_, win)
    local trouble = vim.w[win].trouble

    return trouble
      and trouble.position == position
      and trouble.type == "split"
      and trouble.relative == "editor"
      and not vim.w[win].trouble_preview
  end
end

local lsp_view = edgy.view("LSP", "trouble", {
  filter = trouble_filter("right"),
})

local problems_view = edgy.view("Problems", "trouble", {
  filter = trouble_filter("bottom"),
})

return {
  {
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
        edgy.with_focus(problems_view, "Trouble diagnostics toggle focus=false filter.buf=0"),
        desc = "Buffer diagnostics",
      },
      {
        "<leader>xD",
        edgy.with_focus(problems_view, "Trouble diagnostics toggle focus=false"),
        desc = "Workspace diagnostics",
      },
      { "<leader>xs", edgy.with_focus(lsp_view, "Trouble symbols toggle focus=false"), desc = "Symbols" },
      {
        "<leader>xl",
        edgy.with_focus(lsp_view, "Trouble lsp toggle focus=false win.position=right"),
        desc = "LSP definitions/references",
      },
      { "<leader>xL", edgy.with_focus(problems_view, "Trouble loclist toggle focus=false"), desc = "Location list" },
      { "<leader>xQ", edgy.with_focus(problems_view, "Trouble qflist toggle focus=false"), desc = "Quickfix list" },
    },
  },
  edgy.view_spec("right", lsp_view),
  edgy.view_spec("bottom", problems_view),
}
