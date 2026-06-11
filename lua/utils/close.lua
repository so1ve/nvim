local M = {}

local function buffers()
  return vim.tbl_filter(function(buf)
    return vim.bo[buf.bufnr].buftype == "" and vim.api.nvim_buf_get_name(buf.bufnr) ~= ""
  end, vim.fn.getbufinfo({ buflisted = 1 }))
end

local function close_window()
  pcall(vim.api.nvim_win_close, vim.api.nvim_get_current_win(), false)
end

function M.close_current()
  local q = vim.fn.maparg("q", "n", false, true)

  if q.buffer == 1 and q.rhs ~= "<Nop>" then
    if q.callback then
      q.callback()
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(q.rhs, true, false, true), "mx", false)
    end

    return
  end

  local buf = vim.api.nvim_get_current_buf()

  if
    not vim.bo[buf].buflisted
    or vim.bo[buf].buftype ~= ""
    or vim.api.nvim_buf_get_name(buf) == ""
    or #vim.fn.win_findbuf(buf) > 1
  then
    close_window()
    return
  end

  if #buffers() <= 1 then
    vim.api.nvim_buf_delete(buf, {})
    close_window()
    return
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
