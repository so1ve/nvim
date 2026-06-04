local hacks = require("utils.hacks")
local windows = require("utils.windows")

local M = {}

local function status_window()
  local current = vim.api.nvim_get_current_win()

  if windows.is_work_win(current) then
    return current
  end

  return windows.preferred_work_window()
end

local function restore_replaced_buffer(buffer)
  local old_buf = buffer.old_buf
  buffer.old_buf = nil

  if not old_buf or old_buf == buffer.handle or not vim.api.nvim_buf_is_loaded(old_buf) then
    return
  end

  for _, win in ipairs(vim.fn.win_findbuf(buffer.handle)) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_buf(win, old_buf)
    end
  end
end

function M.patch()
  hacks.on_module("neogit.buffers.status", function(status)
    hacks.wrap(status, "status_replace_work_window", "open", function(open)
      return function(self, kind)
        if kind then
          return open(self, kind)
        end

        local win = status_window()

        if win then
          vim.api.nvim_set_current_win(win)
        end

        return open(self, "replace")
      end
    end)
  end)

  hacks.on_module("neogit.lib.buffer", function(buffer)
    hacks.wrap(buffer, "status_restore_old_buffer", "close", function(close)
      return function(self, force)
        if self.name ~= "NeogitStatus" or self.kind ~= "replace" then
          return close(self, force)
        end

        if self.old_cwd then
          vim.api.nvim_set_current_dir(self.old_cwd)
          self.old_cwd = nil
        end

        restore_replaced_buffer(self)

        if vim.api.nvim_buf_is_valid(self.handle) then
          vim.api.nvim_buf_delete(self.handle, { force = force or false })
        end
      end
    end)
  end)
end

return M
