local edgy = require("integrations.edgy")

local function add_view(opts, position, view)
  opts[position] = opts[position] or {}
  table.insert(opts[position], view)
end

return {
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>uw",
        function()
          require("edgy").select()
        end,
        desc = "Select layout window",
      },
    },
    opts = function(_, opts)
      opts.animate = {
        enabled = false,
      }
      opts.options = {
        left = { size = 0.25 },
        right = { size = 0.25 },
        bottom = { size = 12 },
      }

      add_view(opts, "bottom", edgy.view("Quickfix", "qf"))
      add_view(
        opts,
        "bottom",
        edgy.view("Help", "help", {
          size = { height = 20 },
        })
      )
    end,
  },
  edgy.neo_tree_exclusion_spec({ "terminal", "qf", "edgy", "help" }),
}
