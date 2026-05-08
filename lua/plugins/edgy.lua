local edgy = require("config.edgy")
local layout = edgy.layout

local function add_view(opts, position, view)
  opts[position] = opts[position] or {}
  table.insert(opts[position], view)
end

local function add_language_views(opts)
  local language_views = require("config.languages").edgy_views()

  for position, views in pairs(language_views) do
    for _, view in ipairs(views) do
      add_view(opts, position, view)
    end
  end
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
        right = { size = layout.right.width },
        bottom = { size = layout.bottom.height },
      }

      add_language_views(opts)
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
}
