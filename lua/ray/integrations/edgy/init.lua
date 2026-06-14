local focus = require("ray.integrations.edgy.focus")

local M = {}

local function open_view(open, ...)
  if type(open) == "function" then
    return open(...)
  elseif type(open) == "string" then
    return vim.cmd(open)
  end

  error("ray.integrations.edgy.with_focus opener must be a function or command string")
end

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

M.find_view_win = focus.find_view_win
M.focus_view = focus.focus_view
M.focus_view_when_available = focus.focus_view_when_available

function M.with_focus(view, open, opts)
  return function(...)
    local focus_opts = vim.tbl_extend("force", { tabpage = vim.api.nvim_get_current_tabpage() }, opts or {})
    local had_view = M.find_view_win(view, focus_opts.tabpage) ~= nil
    local result = open_view(open, ...)

    if had_view and not M.find_view_win(view, focus_opts.tabpage) then
      return result
    end

    M.focus_view_when_available(view, focus_opts)

    return result
  end
end

return M
