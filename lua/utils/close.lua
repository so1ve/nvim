local M = {}
local editor_windows = require("utils.editor_windows")

function M.setup()
  editor_windows.setup()
end

function M.close_current()
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()

  if editor_windows.should_close(win, bufnr) then
    local ok = pcall(vim.cmd.close)

    if ok then
      return
    end
  end

  Snacks.bufdelete()
end

function M.quit_all()
  local pickers = require("snacks.picker").get({ tab = false })

  for _, picker in ipairs(pickers) do
    picker:close()
  end

  if #pickers > 0 then
    vim.schedule(function()
      vim.cmd("confirm qall")
    end)
  else
    vim.cmd("confirm qall")
  end
end

return M
