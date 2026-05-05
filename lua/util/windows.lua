local M = {}

-- Dashboard events can cascade through WinNew/WinEnter/BufWinEnter in one layout update.
-- Coalesce them so cleanup runs once after Neovim finishes the current autocmd cycle.
local dashboard_scheduled = false

function M.is_file(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" and vim.bo[bufnr].buflisted
end

local function is_normal_win(win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ""
end

local function is_dashboard(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "snacks_dashboard"
end

local function is_file_win(win)
  return is_normal_win(win) and M.is_file(vim.api.nvim_win_get_buf(win))
end

function M.has_many_files(wins)
  local file_win_count = 0

  for _, win in ipairs(wins) do
    if is_file_win(win) then
      file_win_count = file_win_count + 1

      if file_win_count > 1 then
        return true
      end
    end
  end

  return false
end

local function dismiss_dashboard()
  local has_work_window = false
  local dashboard_buffers = {}
  local work_win

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_normal_win(win) then
      local bufnr = vim.api.nvim_win_get_buf(win)

      if is_dashboard(bufnr) then
        dashboard_buffers[bufnr] = true
      elseif vim.bo[bufnr].buflisted then
        -- A listed non-dashboard buffer means the user has opened real work.
        -- Unlisted sidebars such as neo-tree should not dismiss the startup dashboard.
        has_work_window = true
        work_win = work_win or win
      end
    end
  end

  -- Keep the dashboard visible for pure UI sidebars; dismiss it only once a
  -- listed work buffer exists somewhere in the current tab.
  if not has_work_window then
    return
  end

  local current_win = vim.api.nvim_get_current_win()

  for bufnr in pairs(dashboard_buffers) do
    -- Snacks tears down its dashboard augroup on buffer delete/wipeout.
    -- Deleting the buffer removes the dashboard window without leaving a scratch window.
    if vim.api.nvim_buf_is_valid(bufnr) then
      pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    end
  end

  if vim.api.nvim_win_is_valid(current_win) then
    pcall(vim.api.nvim_set_current_win, current_win)
  elseif work_win and vim.api.nvim_win_is_valid(work_win) then
    pcall(vim.api.nvim_set_current_win, work_win)
  end
end

local function schedule_dashboard()
  if dashboard_scheduled then
    return
  end

  dashboard_scheduled = true
  vim.schedule(function()
    dashboard_scheduled = false
    dismiss_dashboard()
  end)
end

function M.setup_dashboard()
  local group = vim.api.nvim_create_augroup("RaySnacksDashboardLifecycle", { clear = true })

  -- Edgy-managed tools may appear via different window events depending on the
  -- plugin. Funnel all likely entry points through the scheduled cleanup above.
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "WinNew" }, {
    group = group,
    desc = "Dismiss dashboard when a listed work buffer appears",
    callback = schedule_dashboard,
  })

  schedule_dashboard()
end

return M
