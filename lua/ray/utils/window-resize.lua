local M = {}

function M.resize(dim, amount)
  local edgy_win = require("edgy.editor").get_win()

  if edgy_win then
    edgy_win:resize(dim, amount)
    require("edgy.layout").update()

    return
  end

  local winid = vim.api.nvim_get_current_win()

  if vim.api.nvim_win_get_config(winid).relative == "" then
    local command = dim == "width" and "vertical resize" or "resize"
    local prefix = amount > 0 and "+" or ""

    vim.cmd(command .. " " .. prefix .. amount)
  end
end

function M.equalize()
  local edgy_win = require("edgy.editor").get_win()

  if edgy_win then
    edgy_win.view.edgebar:equalize()
    return
  end

  local winid = vim.api.nvim_get_current_win()

  if vim.api.nvim_win_get_config(winid).relative == "" then
    vim.cmd("wincmd =")
  end
end

return M
