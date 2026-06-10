local hacks = require("utils.hacks")

local M = {}

function M.patch()
  hacks.on_module("neogit.lib.buffer", function(Buffer)
    hacks.wrap(Buffer, "neogit_replace_close_restores_window", "close", function(close)
      return function(buffer, ...)
        if buffer.kind == "replace" then
          local win = buffer.win_handle

          if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buffer.handle then
            local old = buffer.old_buf
            local buf = old and vim.api.nvim_buf_is_valid(old) and vim.api.nvim_buf_is_loaded(old) and old
              or vim.api.nvim_create_buf(true, false)

            vim.api.nvim_win_set_buf(win, buf)
          end
        end

        return close(buffer, ...)
      end
    end)
  end)
end

return M
