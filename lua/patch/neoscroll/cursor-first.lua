-- Cursor-first page scrolling for Neoscroll.
-- Purpose: make <C-u>/<C-d>/<C-b>/<C-f> move the cursor inside the viewport
-- first, then scroll the window once the cursor reaches the scrolloff edge.
-- Behavior: page keys stay smooth and respect Neoscroll timing while avoiding
-- the default behavior that pins the cursor near the wrong viewport edge.
-- Implementation: wrap Neoscroll's per-tick movement decision with utils.hacks;
-- only active page-scroll mappings use cursor-only ticks before falling back to
-- Neoscroll's original window+cursor logic.

local M = {}
local hacks = require("utils.hacks")

local active = false

local function half_scroll_count()
  return vim.v.count > 0 and vim.v.count or vim.wo.scroll
end

local function full_scroll_count()
  return vim.fn.winheight(0) * (vim.v.count > 0 and vim.v.count or 1)
end

local function cursor_should_move_alone(data, direction)
  local half_window = math.floor(data.window_height / 2)
  local top_edge = data.scrolloff >= half_window and half_window or data.scrolloff + 1
  local bottom_edge = data.scrolloff >= half_window and half_window or data.window_height - data.scrolloff

  return direction < 0 and data.cursor_win_line > top_edge or direction > 0 and data.cursor_win_line < bottom_edge
end

local function patch_neoscroll()
  local logic = require("neoscroll.logic")
  local scroll = require("neoscroll.scroll")

  local function win_call(winid, fn)
    if winid == 0 then
      return fn()
    end

    return vim.api.nvim_win_call(winid, fn)
  end

  local function movement_state(winid)
    local cursor = vim.api.nvim_win_get_cursor(winid)

    return win_call(winid, function()
      return {
        col = cursor[2],
        line = cursor[1],
        topline = vim.fn.line("w0"),
        virtcol = vim.fn.virtcol("."),
        winline = vim.fn.winline(),
      }
    end)
  end

  local function same_state(before, after)
    return before.line == after.line
      and before.col == after.col
      and before.virtcol == after.virtcol
      and before.winline == after.winline
      and before.topline == after.topline
  end

  hacks.wrap(logic, "neoscroll.cursor_first.who_scrolls", "who_scrolls", function(who_scrolls)
    return function(data, move_cursor, direction)
      if active and move_cursor then
        if cursor_should_move_alone(data, direction) then
          return false, true
        end

        scroll.initial_cursor_win_line = data.cursor_win_line
      end

      return who_scrolls(data, move_cursor, direction)
    end
  end)

  hacks.wrap(scroll, "neoscroll.cursor_first.scroll_one_line", "scroll_one_line", function(scroll_one_line)
    return function(self, ...)
      local winid = self.opts.winid or 0
      local before = movement_state(winid)
      local success = scroll_one_line(self, ...)

      if not success then
        return false
      end

      return not same_state(before, movement_state(winid))
    end
  end)

  hacks.wrap(scroll, "neoscroll.cursor_first.tear_down", "tear_down", function(tear_down)
    return function(self, ...)
      active = false

      return tear_down(self, ...)
    end
  end)
end

local function scroll(lines, duration)
  active = true

  require("neoscroll").scroll(lines, {
    move_cursor = true,
    duration = duration,
  })

  if not require("neoscroll.scroll").scrolling then
    active = false
  end
end

local function map(lhs, lines, duration, desc)
  vim.keymap.set({ "n", "v", "x" }, lhs, function()
    scroll(lines(), duration)
  end, { desc = desc, silent = true })
end

function M.setup()
  patch_neoscroll()

  map("<C-u>", function()
    return -half_scroll_count()
  end, 250, "Move cursor half page up")

  map("<C-d>", half_scroll_count, 250, "Move cursor half page down")

  map("<C-b>", function()
    return -full_scroll_count()
  end, 450, "Move cursor page up")

  map("<C-f>", full_scroll_count, 450, "Move cursor page down")
end

return M
