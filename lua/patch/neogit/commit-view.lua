local hacks = require("utils.hacks")
local windows = require("utils.windows")

local M = {}

local function current_filetype()
  return vim.bo[vim.api.nvim_get_current_buf()].filetype
end

local function preferred_work_window()
  local previous = vim.fn.win_getid(vim.fn.winnr("#"))

  if windows.is_work_win(previous) then
    return previous
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if windows.is_work_win(win) then
      return win
    end
  end
end

local function open_in_work_window(open, self, kind)
  if kind or current_filetype() ~= "NeogitStatus" then
    return open(self, kind)
  end

  local win = preferred_work_window()

  if not win then
    return open(self, kind)
  end

  vim.api.nvim_set_current_win(win)

  return open(self, "replace")
end

function M.patch()
  hacks.on_module("neogit.buffers.commit_view", function(commit_view)
    if type(commit_view) ~= "table" or type(commit_view.open) ~= "function" then
      return
    end

    hacks.wrap(commit_view, "neogit_commit_view_work_window", "open", function(open)
      return function(self, kind)
        return open_in_work_window(open, self, kind)
      end
    end)
  end)
end

return M
