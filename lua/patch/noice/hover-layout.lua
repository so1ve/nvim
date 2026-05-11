-- Noice LSP hover layout patch.
-- Purpose: keep hover windows anchored to the source-code cursor while keeping
-- horizontal placement inside the source window's currently available screen
-- width. This module owns hover positioning and the active hover view.
-- Behavior: on source-window scroll/resize it asks Noice to recompute the hover
-- layout.
-- Implementation: monkey-patches `noice.view.nui:get_layout()` for LSP hover
-- views only, first applying markdown visual sizing, then replacing the final
-- NUI layout with editor-relative row/col coordinates.

local hover = require("patch.noice.hover")
local markdown_width = require("patch.noice.markdown-width")
local hacks = require("utils.hacks")

local M = {}

-- The currently displayed LSP hover view. Noice does not relayout hover windows
-- on scroll, so we keep a handle and ask it to recompute its layout ourselves.
local active
local pending = false

local function clamp(x, lo, hi)
  if hi < lo then
    return lo
  end

  return math.min(math.max(x, lo), hi)
end

local function round(x)
  return math.floor(x + 0.5)
end

local function is_mounted(view)
  local ok, mounted = pcall(view.is_mounted, view)

  return ok and mounted or false
end

local function source_win(view)
  local win = view._ray_hover_src_win

  if win and vim.api.nvim_win_is_valid(win) and is_mounted(view) then
    return win
  end

  local cur = vim.api.nvim_get_current_win()
  local hover_win = view._nui and view._nui.winid

  -- Once the hover exists, the current window may become the hover window during
  -- scroll/documentation interactions. Keep using the source code window for
  -- screenrow()/screencol(), otherwise the popup starts positioning itself.
  if cur ~= hover_win and vim.api.nvim_win_is_valid(cur) then
    view._ray_hover_src_win = cur
  end

  win = view._ray_hover_src_win
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return nil
  end

  return win
end

local function source_bounds(win)
  local pos = vim.api.nvim_win_get_position(win)
  local width = vim.api.nvim_win_get_width(win)

  return pos[2] or 0, width
end

local function cursor(win)
  local cur_pos = vim.api.nvim_win_get_cursor(win)
  -- screenrow()/screencol() read the active UI cursor. Once the hover is
  -- focused, that cursor belongs to the hover window, so ask for the source
  -- window's cursor screen position explicitly instead.
  local pos = vim.fn.screenpos(win, cur_pos[1], cur_pos[2] + 1)

  return pos.row or 0, (pos.curscol or pos.col or 0) - 1
end

local function place(view, layout)
  local size = layout.size

  if not (size and type(size.width) == "number" and type(size.height) == "number") then
    return layout
  end

  local rows = vim.o.lines
  local pad = 2
  -- Approximate the extra cells used by the rounded border/padding. The actual
  -- NUI border window is separate, so leave a little space at the screen edges.
  local bw = 2
  local bh = 1
  local src_win = source_win(view)

  if not src_win then
    return layout
  end

  local src_left, src_width = source_bounds(src_win)
  local w = math.min(size.width, math.max(1, src_width - (pad + bw) * 2))
  local h = size.height
  local sr, sc = cursor(src_win)

  if not (sr and sc) or sr <= 0 or sc < 0 then
    return layout
  end

  local top = pad + bh
  local bot = math.max(top, rows - h - bh - pad)
  local down = sr + 1
  local up = sr - h - bh * 2
  -- Keep the vertical behavior cursor-following: prefer below the symbol, flip
  -- above when there is not enough space below.
  local row = down + h + bh <= rows - pad and down or up

  local left = src_left + pad + bw
  local right = math.max(left, src_left + src_width - w - bw - pad)
  -- Horizontally, follow the source cursor and clamp only to the source window's
  -- available width. This naturally avoids any left split/sidebar when present,
  -- but lets the hover reach the editor edge when the source window owns it.
  local col = round(sc - w / 2)

  layout.relative = "editor"
  layout.anchor = "NW"
  layout.position = {
    row = clamp(row, top, bot),
    col = clamp(col, left, right),
  }
  layout.size.width = w

  return layout
end

local function relayout()
  if pending then
    return
  end

  pending = true
  vim.schedule(function()
    pending = false

    if not (active and hover.is(active) and active._nui and active:is_mounted()) then
      return
    end

    pcall(function()
      active:update_layout()
    end)
  end)
end

local function watch_scroll()
  -- Scrolling changes screenrow()/screencol() without necessarily causing Noice
  -- to rebuild the hover, so schedule a debounced layout refresh.
  vim.api.nvim_create_autocmd({ "WinScrolled", "WinResized", "VimResized" }, {
    group = vim.api.nvim_create_augroup("RayNoiceHoverLayout", { clear = true }),
    callback = function(args)
      local hover_win = active and active._nui and active._nui.winid

      if args.event == "WinScrolled" and hover_win and tostring(hover_win) == args.match then
        return
      end

      relayout()
    end,
  })
end

function M.current()
  return active
end

function M.patch()
  local view = require("noice.view.nui")

  if
    hacks.wrap(view, "noice.hover-layout", "get_layout", function(get_layout)
      -- Replace only the final layout for LSP hover views. Non-hover Noice views
      -- continue using Noice's original layout calculation unchanged.
      return function(self)
        local layout = get_layout(self)

        if not hover.is(self) then
          return layout
        end

        layout = markdown_width.fix_layout(self, layout)

        -- Noice/NUI can do cursor-relative row+col or editor-relative row+col, but
        -- not cursor-relative row with center-biased editor-relative col. Patch the
        -- final computed layout so we can mix those behaviors only for LSP hover.
        active = self

        return place(self, layout)
      end
    end)
  then
    watch_scroll()
    hacks.cleanup(function()
      active = nil
      pending = false
      pcall(vim.api.nvim_del_augroup_by_name, "RayNoiceHoverLayout")
    end)
  end
end

return M
