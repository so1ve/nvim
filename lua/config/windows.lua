local M = {}

local function is_regular_buffer(bufnr)
  return vim.bo[bufnr].buftype == "" and vim.bo[bufnr].buflisted
end

local function is_regular_window(win)
  local win_config = vim.api.nvim_win_get_config(win)
  local bufnr = vim.api.nvim_win_get_buf(win)

  return win_config.relative == "" and is_regular_buffer(bufnr)
end

local function has_multiple_regular_windows(wins)
  local regular_window_count = 0

  for _, win in ipairs(wins) do
    if is_regular_window(win) then
      regular_window_count = regular_window_count + 1

      if regular_window_count > 1 then
        return true
      end
    end
  end

  return false
end

local function is_normal_window(win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ""
end

local function is_dashboard_window(win)
  local bufnr = vim.api.nvim_win_get_buf(win)

  return vim.bo[bufnr].filetype == "snacks_dashboard"
end

local function has_other_window(wins)
  for _, win in ipairs(wins) do
    local bufnr = vim.api.nvim_win_get_buf(win)

    if not is_dashboard_window(win) and vim.bo[bufnr].buflisted then
      return true
    end
  end

  return false
end

local function close_extra_dashboard_windows()
  local normal_wins = vim.tbl_filter(is_normal_window, vim.api.nvim_tabpage_list_wins(0))
  if not has_other_window(normal_wins) then
    return
  end

  local current_win = vim.api.nvim_get_current_win()

  for _, win in ipairs(normal_wins) do
    if is_dashboard_window(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end

  if vim.api.nvim_win_is_valid(current_win) then
    pcall(vim.api.nvim_set_current_win, current_win)
  end
end

function M.setup_dashboard_lifecycle()
  local group = vim.api.nvim_create_augroup("RaySnacksDashboardLifecycle", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "WinNew" }, {
    group = group,
    desc = "Close dashboard when another window appears",
    callback = close_extra_dashboard_windows,
  })
end

function M.close_buffer_or_window()
  local bufnr = vim.api.nvim_get_current_buf()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local has_multiple_windows = #wins > 1
  local should_delete_buffer = is_regular_buffer(bufnr)
    and (not has_multiple_windows or not has_multiple_regular_windows(wins))

  if should_delete_buffer then
    Snacks.bufdelete()

    return
  end

  if has_multiple_windows then
    vim.cmd.close()

    return
  end

  vim.cmd.bdelete()
end

function M.quit_all()
  local ok, picker = pcall(require, "snacks.picker")
  local active_pickers = ok and picker.get({ tab = false }) or {}

  if #active_pickers > 0 then
    for _, active_picker in ipairs(active_pickers) do
      active_picker:close()
    end

    vim.schedule(function()
      vim.cmd("confirm qall")
    end)

    return
  end

  vim.cmd("confirm qall")
end

return M
