-- Snacks dashboard stale-window patch.
-- Purpose: avoid dashboard resize crashes when a picker/explorer action closes
-- the original dashboard window before Snacks' WinResized autocmd runs.
-- Behavior: recover the current dashboard window from its buffer when possible;
-- otherwise skip size/update work instead of calling Neovim window APIs with a
-- stale window id.
-- Implementation: patches the exported dashboard class methods before
-- `Snacks.setup()`, so the upstream WinResized callback keeps its flow but calls
-- guarded `size()` / `update()` methods.

local M = {}
local hacks = require("utils.hacks")

local function valid_win(win)
  return type(win) == "number" and vim.api.nvim_win_is_valid(win)
end

local function dashboard_win(self)
  if valid_win(self.win) then
    return self.win
  end

  if not (self.buf and vim.api.nvim_buf_is_valid(self.buf)) then
    return nil
  end

  local win = vim.fn.bufwinid(self.buf)

  if valid_win(win) then
    self.win = win

    return win
  end

  return nil
end

function M.patch()
  local Dashboard = require("snacks.dashboard").Dashboard

  hacks.wrap(Dashboard, "snacks.dashboard.size", "size", function(size)
    return function(self)
      if not dashboard_win(self) then
        return self._size
      end

      return size(self)
    end
  end)

  hacks.wrap(Dashboard, "snacks.dashboard.update", "update", function(update)
    return function(self)
      if not dashboard_win(self) then
        return
      end

      return update(self)
    end
  end)
end

return M
