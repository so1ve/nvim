local edgy = require("config.edgy")
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
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xD", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
      {
        "<leader>xl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP definitions/references",
      },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
  },
  edgy.view_spec(
    "right",
    edgy.view("LSP", "trouble", {
      filter = trouble_filter("right"),
    })
  ),
  edgy.view_spec(
    "bottom",
    edgy.view("Problems", "trouble", {
      filter = trouble_filter("bottom"),
    })
  ),
  edgy.neo_tree_exclusion_spec({ "Trouble", "trouble" }),
}
