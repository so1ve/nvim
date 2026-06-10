local windows = require("utils.windows")

local M = {}

local main_windows = {}

local function remember(win)
  if windows.is_work_win(win) then
    main_windows[win] = true
  elseif windows.is_normal_win(win) then
    vim.schedule(function()
      if windows.is_normal_win(win) and windows.is_empty_unnamed_file(vim.api.nvim_win_get_buf(win)) then
        main_windows[win] = true
      end
    end)
  end
end

local function is_main(win)
  return windows.is_normal_win(win) and (main_windows[win] == true or windows.is_work_win(win))
end

local function is_placeholder(win)
  return is_main(win) and windows.is_empty_unnamed_file(vim.api.nvim_win_get_buf(win))
end

function M.setup()
  remember(vim.api.nvim_get_current_win())

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    callback = function()
      remember(vim.api.nvim_get_current_win())
    end,
  })
end

function M.pick()
  local current = vim.api.nvim_get_current_win()

  if windows.is_work_win(current) or is_placeholder(current) then
    return current
  end

  local previous = vim.fn.win_getid(vim.fn.winnr("#"))

  if windows.is_work_win(previous) or is_placeholder(previous) then
    return previous
  end

  local placeholder

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if windows.is_work_win(win) then
      return win
    elseif not placeholder and is_placeholder(win) then
      placeholder = win
    end
  end

  return placeholder
end

function M.should_close(win, bufnr)
  return not is_main(win) and #vim.api.nvim_tabpage_list_wins(0) > 1 and #vim.fn.win_findbuf(bufnr) == 1
end

return M
