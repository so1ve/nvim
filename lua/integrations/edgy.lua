local windows = require("utils.windows")

local M = {}

local function open_view(open, ...)
  if type(open) == "function" then
    return open(...)
  elseif type(open) == "string" then
    return vim.cmd(open)
  end

  error("integrations.edgy.with_focus opener must be a function or command string")
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

function M.find_view_win(view, tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()

  if not vim.api.nvim_tabpage_is_valid(tabpage) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if windows.is_normal_win(win) then
      local buf = vim.api.nvim_win_get_buf(win)

      if vim.bo[buf].filetype == view.ft and (not view.filter or view.filter(buf, win)) then
        return win
      end
    end
  end

  return nil
end

function M.focus_view(view, opts)
  opts = opts or {}

  local attempts = opts.attempts ~= nil and opts.attempts or 10
  local interval = opts.interval ~= nil and opts.interval or 20
  local tabpage = opts.tabpage or vim.api.nvim_get_current_tabpage()

  local function focus(remaining)
    if not vim.api.nvim_tabpage_is_valid(tabpage) or vim.api.nvim_get_current_tabpage() ~= tabpage then
      return false
    end

    local win = M.find_view_win(view, tabpage)

    if win then
      vim.api.nvim_set_current_win(win)

      return true
    end

    if remaining > 0 then
      vim.defer_fn(function()
        focus(remaining - 1)
      end, interval)
    end

    return false
  end

  return focus(attempts)
end

function M.with_focus(view, open, opts)
  return function(...)
    local result = open_view(open, ...)
    M.focus_view(view, opts)

    return result
  end
end

return M
