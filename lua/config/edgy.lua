local M = {}

local function open_view(open)
  if type(open) == "function" then
    open()
  elseif type(open) == "string" then
    vim.cmd(open)
  else
    error("edgy.with_focus opener must be a function or command string")
  end
end

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

function M.find_view_win(view)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
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

  local function focus(remaining)
    local win = M.find_view_win(view)

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
  return function()
    open_view(open)
    M.focus_view(view, opts)
  end
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
