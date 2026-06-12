local hacks = require("utils.hacks")

local M = {}
local RESTORE_BUF = "neogit_replace_restore_buf"

function M.patch()
  hacks.on_module("neogit.lib.buffer", function(Buffer)
    hacks.wrap(Buffer, "neogit_replace_close_show", "show", function(show)
      return function(buffer, ...)
        if buffer.kind ~= "replace" then
          return show(buffer, ...)
        end

        local win = vim.api.nvim_get_current_win()
        local old = vim.w[win][RESTORE_BUF] or vim.api.nvim_get_current_buf()
        local opened_win = show(buffer, ...)

        buffer.old_buf = old
        vim.w[opened_win][RESTORE_BUF] = old

        return opened_win
      end
    end)

    hacks.wrap(Buffer, "neogit_replace_close", "close", function(close)
      return function(buffer, ...)
        if buffer.kind == "replace" then
          local win, old = buffer.win_handle, buffer.old_buf
          local current = win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buffer.handle

          if current and old and vim.api.nvim_buf_is_loaded(old) then
            vim.bo[buffer.handle].bufhidden = "hide"
            vim.api.nvim_win_set_buf(win, old)
            vim.w[win][RESTORE_BUF] = nil
          end
        end

        return close(buffer, ...)
      end
    end)
  end)
end

return M
