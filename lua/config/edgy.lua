local M = {}

M.layout = {
  right = {
    width = 0.25,
  },
  bottom = {
    height = 12,
  },
}

function M.view(title, ft, opts)
  return vim.tbl_deep_extend("force", {
    title = title,
    ft = ft,
  }, opts or {})
end

local function add_view(opts, position, view)
  opts[position] = opts[position] or {}
  table.insert(opts[position], view)
end

function M.view_spec(position, view)
  return {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      add_view(opts, position, view)
    end,
  }
end

return M
