local windows = require("ray.utils.windows")

local M = {}

-- Registered only while a with_focus call is waiting for a view. These are
-- lifecycle events, not polling hooks, so idle Neovim has no focus overhead.
local events = { "WinNew", "WinEnter", "BufWinEnter", "BufEnter", "FileType", "TabEnter" }
local autocmd ---@type integer?
local scheduled = false
local next_id = 0
local watchers = {}

local function close_timer(timer)
  if timer then
    pcall(function()
      timer:stop()
    end)
    pcall(function()
      timer:close()
    end)
  end
end

local function stop_watcher(id)
  local watcher = watchers[id]

  if not watcher then
    return
  end

  watchers[id] = nil
  close_timer(watcher.timer)

  if not next(watchers) and autocmd then
    pcall(vim.api.nvim_del_autocmd, autocmd)
    autocmd = nil
    scheduled = false
  end
end

local function check_watchers()
  scheduled = false

  local ids = {}

  for id in pairs(watchers) do
    table.insert(ids, id)
  end

  for _, id in ipairs(ids) do
    local watcher = watchers[id]

    if watcher then
      if not vim.api.nvim_tabpage_is_valid(watcher.tabpage) then
        stop_watcher(id)
      elseif M.focus_view(watcher.view, { tabpage = watcher.tabpage }) then
        stop_watcher(id)
      end
    end
  end
end

local function schedule_check()
  if scheduled then
    return
  end

  scheduled = true
  vim.schedule(check_watchers)
end

local function ensure_autocmd()
  if autocmd then
    return
  end

  autocmd = vim.api.nvim_create_autocmd(events, {
    callback = schedule_check,
  })
end

local function start_deadline(id, timeout)
  local timer = assert(vim.uv.new_timer())

  -- One-shot cleanup only; focus attempts are driven by events above.
  timer:start(timeout, 0, function()
    vim.schedule(function()
      stop_watcher(id)
    end)
  end)

  return timer
end

function M.find_view_win(view, tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()

  if not vim.api.nvim_tabpage_is_valid(tabpage) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if windows.is_normal_win(win) then
      local buf = vim.api.nvim_win_get_buf(win)

      if vim.bo[buf].filetype == view.ft and (not view.filter or view.filter(buf, win)) then
        return win
      end
    end
  end

  return nil
end

function M.focus_view(view, opts)
  opts = opts or {}

  local tabpage = opts.tabpage or vim.api.nvim_get_current_tabpage()

  if not vim.api.nvim_tabpage_is_valid(tabpage) or vim.api.nvim_get_current_tabpage() ~= tabpage then
    return false
  end

  local win = M.find_view_win(view, tabpage)

  if not win then
    return false
  end

  vim.api.nvim_set_current_win(win)

  return true
end

function M.focus_view_when_available(view, opts)
  opts = opts or {}

  if M.focus_view(view, opts) then
    return true
  end

  local timeout = opts.timeout ~= nil and opts.timeout or 3000

  if timeout <= 0 then
    return false
  end

  next_id = next_id + 1

  local id = next_id

  watchers[id] = {
    view = view,
    tabpage = opts.tabpage or vim.api.nvim_get_current_tabpage(),
  }
  watchers[id].timer = start_deadline(id, timeout)

  ensure_autocmd()
  schedule_check()

  return false
end

return M
