local edgy = require("integrations.edgy")

local function add_view(opts, position, view)
  opts[position] = opts[position] or {}
  table.insert(opts[position], view)
end

local resize_step = 2

local function resize_view(win, dim, amount)
  if not vim.api.nvim_win_is_valid(win.win) then
    return
  end

  local get_size = dim == "width" and vim.api.nvim_win_get_width or vim.api.nvim_win_get_height
  local key = "edgy_" .. dim
  local target = math.max(1, get_size(win.win) + amount)

  vim.w[win.win][key] = target
  require("edgy.layout").update()

  if not vim.api.nvim_win_is_valid(win.win) then
    return
  end

  local applied = get_size(win.win)

  if applied ~= target then
    vim.w[win.win][key] = applied
    require("edgy.layout").update()
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
        left = { size = 0.25 },
        right = { size = 0.25 },
        bottom = { size = 12 },
      }
      opts.keys = {
        ["<C-Right>"] = function(win)
          resize_view(win, "width", resize_step)
        end,
        ["<C-Left>"] = function(win)
          resize_view(win, "width", -resize_step)
        end,
        ["<C-Up>"] = function(win)
          resize_view(win, "height", resize_step)
        end,
        ["<C-Down>"] = function(win)
          resize_view(win, "height", -resize_step)
        end,
        ["<C-=>"] = function(win)
          win.view.edgebar:equalize()
        end,
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
      local patch = require("patch.edgy")

      patch.patch()
      require("edgy").setup(opts)
      patch.no_main()
    end,
  },
  edgy.neo_tree_exclusion_spec({ "terminal", "qf", "edgy", "help" }),
}
