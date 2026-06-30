-- planned to migrate to mini.windows once released
local edgy = require("ray.integrations.edgy")

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
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
          size = { height = 20 },
        })
      )
      add_view(
        opts,
        "bottom",
        edgy.view("Terminal Buffer", "", {
          filter = function(buf, win)
            return vim.bo[buf].buftype == "terminal" and vim.api.nvim_win_get_config(win).relative == ""
          end,
        })
      )
    end,
    config = function(_, opts)
      local patch = require("ray.patch.edgy")

      patch.patch()
      require("edgy").setup(opts)
    end,
  },
}
