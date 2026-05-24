local M = {}

M.layout = {
  left = {
    width = 0.25,
  },
  right = {
    width = 0.25,
  },
  bottom = {
    height = 12,
  },
}

function M.view(title, ft, opts)
  return vim.tbl_extend("force", {
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

local function as_list(values)
  return type(values) == "string" and { values } or values
end

local function add_neo_tree_exclusions(opts, filetypes)
  opts.open_files_do_not_replace_types = opts.open_files_do_not_replace_types or {}
  local types = opts.open_files_do_not_replace_types

  for _, filetype in ipairs(as_list(filetypes)) do
    if not vim.list_contains(types, filetype) then
      table.insert(types, filetype)
    end
  end
end

function M.neo_tree_exclusion_spec(filetypes)
  return {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    opts = function(_, opts)
      add_neo_tree_exclusions(opts, filetypes)
    end,
  }
end

return M
