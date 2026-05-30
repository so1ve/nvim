-- FFF picker backdrop patch.
-- Purpose: dim the editor behind fff's floating picker, matching Snacks'
-- backdrop behavior without changing fff's upstream layout code.
-- Behavior: create one non-focusable editor-sized float below the picker windows;
-- resize it with the picker and always close it with the picker.

local M = {}
local hacks = require("utils.hacks")

local BACKDROP_ZINDEX = 50
local BACKDROP_BLEND = 60
local BACKDROP_GROUP = "SnacksBackdrop_000000"

local function valid_win(win)
  return type(win) == "number" and vim.api.nvim_win_is_valid(win)
end

local function valid_buf(buf)
  return type(buf) == "number" and vim.api.nvim_buf_is_valid(buf)
end

local function backdrop_config()
  return {
    relative = "editor",
    row = 0,
    col = 0,
    width = math.max(1, vim.o.columns),
    height = math.max(1, vim.o.lines - vim.o.cmdheight),
    style = "minimal",
    border = "none",
    focusable = false,
    noautocmd = true,
    zindex = BACKDROP_ZINDEX,
  }
end

local function ensure_highlight()
  vim.api.nvim_set_hl(0, BACKDROP_GROUP, { bg = "#000000" })
end

local function set_window_options(win)
  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:" .. BACKDROP_GROUP .. ",EndOfBuffer:" .. BACKDROP_GROUP,
    { win = win }
  )
  vim.api.nvim_set_option_value("winblend", BACKDROP_BLEND, { win = win })
  vim.api.nvim_set_option_value("colorcolumn", "", { win = win })
  vim.api.nvim_set_option_value("number", false, { win = win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = win })
  vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
  vim.api.nvim_set_option_value("foldcolumn", "0", { win = win })
  vim.api.nvim_set_option_value("fillchars", "eob: ", { win = win })
end

local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "fff_backdrop", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  return buf
end

local function close_backdrop(picker)
  local state = picker.state

  if valid_win(state.backdrop_win) then
    vim.api.nvim_win_close(state.backdrop_win, true)
  end
  state.backdrop_win = nil

  if valid_buf(state.backdrop_buf) then
    vim.api.nvim_buf_delete(state.backdrop_buf, { force = true })
  end
  state.backdrop_buf = nil
end

local function open_backdrop(picker)
  local state = picker.state

  close_backdrop(picker)
  ensure_highlight()

  state.backdrop_buf = create_buffer()
  state.backdrop_win = vim.api.nvim_open_win(state.backdrop_buf, false, backdrop_config())
  set_window_options(state.backdrop_win)
end

local function sync_backdrop(picker)
  local state = picker.state

  if not state.active then
    close_backdrop(picker)
    return
  end

  if valid_win(state.backdrop_win) then
    vim.api.nvim_win_set_config(state.backdrop_win, backdrop_config())
    return
  end

  open_backdrop(picker)
end

function M.patch()
  hacks.on_module("fff.picker_ui", function(picker)
    hacks.wrap(picker, "fff.backdrop.create_ui", "create_ui", function(create_ui)
      return function(...)
        open_backdrop(picker)

        local result = create_ui(...)

        if not result then
          close_backdrop(picker)
        end

        return result
      end
    end)

    hacks.wrap(picker, "fff.backdrop.relayout", "relayout", function(relayout)
      return function(...)
        local result = relayout(...)
        sync_backdrop(picker)
        return result
      end
    end)

    hacks.wrap(picker, "fff.backdrop.close", "close", function(close)
      return function(...)
        local result = close(...)
        close_backdrop(picker)
        return result
      end
    end)
  end)
end

return M
