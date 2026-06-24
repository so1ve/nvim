-- Cursor-first page scrolling for Neoscroll.
-- Purpose: make <C-u>/<C-d>/<C-b>/<C-f> move the cursor inside the viewport
-- first, then scroll the window once the cursor reaches the scrolloff edge.
-- Behavior: page keys stay smooth and respect Neoscroll timing while avoiding
-- the default behavior that pins the cursor near the wrong viewport edge.
-- Implementation: wrap Neoscroll's per-tick movement decision with utils.hacks;
-- only active page-scroll mappings use cursor-only ticks before falling back to
-- Neoscroll's original window+cursor logic.

local M = {}
local hacks = require("ray.patch.hacks")

local active = false

local function scroll_count(winid, full)
  if full then
    return vim.api.nvim_win_get_height(winid) * (vim.v.count > 0 and vim.v.count or 1)
  end

  return vim.v.count > 0 and vim.v.count or vim.wo[winid].scroll
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

  local function movement(winid)
    return vim.api.nvim_win_call(winid, function()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local view = vim.fn.winsaveview()

      return {
        cursor[1],
        cursor[2],
        view.topline,
        view.skipcol,
        vim.fn.winline(),
        vim.fn.virtcol("."),
      }
    end)
  end

  local function move_visual_line(winid, direction)
    vim.api.nvim_win_call(winid, function()
      vim.cmd.normal({ bang = true, args = { direction > 0 and "gj" or "gk" } })
    end)
  end

  hacks.wrap(logic, "neoscroll.cursor_first.who_scrolls", "who_scrolls", function(who_scrolls)
    return function(data, move_cursor, direction)
      if active and move_cursor then
        local winid = scroll.opts.winid or 0

        if vim.wo[winid].wrap or cursor_should_move_alone(data, direction) then
          return false, true
        end

        scroll.initial_cursor_win_line = data.cursor_win_line
      end

      return who_scrolls(data, move_cursor, direction)
    end
  end)

  hacks.wrap(scroll, "neoscroll.cursor_first.scroll_one_line", "scroll_one_line", function(scroll_one_line)
    return function(self, lines_to_scroll, window_scrolls, cursor_scrolls)
      local winid = self.opts.winid or 0
      local before = movement(winid)

      if active and cursor_scrolls and not window_scrolls and vim.wo[winid].wrap then
        local success = pcall(move_visual_line, winid, lines_to_scroll)
        local moved = success and not vim.deep_equal(before, movement(winid))

        if moved then
          self.relative_line = self.relative_line + (lines_to_scroll > 0 and 1 or -1)
        end

        return moved
      end

      local success = scroll_one_line(self, lines_to_scroll, window_scrolls, cursor_scrolls)

      if not success then
        return false
      end

      return not vim.deep_equal(before, movement(winid))
    end
  end)

  hacks.wrap(scroll, "neoscroll.cursor_first.tear_down", "tear_down", function(tear_down)
    return function(self, ...)
      active = false

      return tear_down(self, ...)
    end
  end)
end

local function scroll(lines, duration, winid)
  active = true

  require("neoscroll").scroll(lines, {
    move_cursor = true,
    duration = duration,
    winid = winid,
  })

  if not require("neoscroll.scroll").scrolling then
    active = false
  end
end

local function map(lhs, lines, duration, desc)
  vim.keymap.set({ "n", "v", "x" }, lhs, function()
    local winid = vim.api.nvim_get_current_win()

    scroll(lines(winid), duration, winid)
  end, { desc = desc, silent = true })
end

function M.scroll_page(direction, winid)
  winid = winid or vim.api.nvim_get_current_win()

  scroll(direction * scroll_count(winid, true), 450, winid)
end

function M.setup()
  patch_neoscroll()

  map("<C-u>", function(winid)
    return -scroll_count(winid)
  end, 250, "Move cursor half page up")

  map("<C-d>", scroll_count, 250, "Move cursor half page down")

  map("<C-b>", function(winid)
    return -scroll_count(winid, true)
  end, 450, "Move cursor page up")

  map("<C-f>", function(winid)
    return scroll_count(winid, true)
  end, 450, "Move cursor page down")
end

return M
