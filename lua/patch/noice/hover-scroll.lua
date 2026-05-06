local hover = require("patch.noice.hover")
local layout = require("patch.noice.hover-layout")

local M = {}

local clamping = false

local function clamp(x, lo, hi)
  if hi < lo then
    return lo
  end

  return math.min(math.max(x, lo), hi)
end

local function ensure_scroll_options(win)
  local util = require("noice.util")

  util.wo(win, { scrolloff = 0 })

  -- Wrapped hover docs need screen-line scrolling. In Neovim that state is
  -- represented by `skipcol`, and `skipcol` is only preserved when the window
  -- has local 'smoothscroll' enabled.
  util.wo(win, { smoothscroll = true })
end

local function text_height(win, opts)
  return vim.api.nvim_win_text_height(win, opts or {}).all
end

local function scroll_limit(win)
  return math.max(0, text_height(win) - vim.api.nvim_win_get_height(win))
end

local function scroll_offset(win)
  local state = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  local lines = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
  local row = clamp((state.topline or 1) - 1, 0, lines)
  local offset = row > 0 and text_height(win, { end_row = row - 1 }) or 0

  if row < lines and (state.skipcol or 0) > 0 then
    -- `topline` is only a logical buffer line. When the first logical line is
    -- partially scrolled because of wrapping, Neovim stores the missing
    -- screen-line part as `skipcol`; include that prefix in the virtual offset
    -- used by our scrollbar and bounds checks.
    offset = offset + text_height(win, { start_row = row, end_row = row, end_vcol = state.skipcol })
  end

  return clamp(offset, 0, text_height(win))
end

local function normal_scroll(win, count, down)
  if count <= 0 then
    return
  end

  local key = vim.api.nvim_replace_termcodes(down and "<C-E>" or "<C-Y>", true, false, true)

  vim.api.nvim_win_call(win, function()
    ensure_scroll_options(win)

    for _ = 1, count do
      vim.cmd("normal! " .. key)
    end
  end)
end

local function scroll_to(win, target)
  target = clamp(target, 0, scroll_limit(win))
  local current = scroll_offset(win)

  if current == target then
    return
  end

  clamping = true
  normal_scroll(win, math.abs(target - current), target > current)
  clamping = false
end

local function clamp_win(win)
  if clamping or not vim.api.nvim_win_is_valid(win) then
    return
  end

  ensure_scroll_options(win)

  local offset = scroll_offset(win)
  local target = clamp(offset, 0, scroll_limit(win))

  if target ~= offset then
    scroll_to(win, target)
  end

  layout.refresh()
end

local function patch_bar()
  local Scrollbar = require("noice.view.scrollbar")

  if Scrollbar._ray_hover_bar_patched then
    return
  end

  Scrollbar._ray_hover_bar_patched = true

  local original_update = Scrollbar.update

  function Scrollbar:update()
    if not self._ray_hover then
      return original_update(self)
    end

    if not vim.api.nvim_win_is_valid(self.winnr) then
      return self:hide()
    end

    local util = require("noice.util")
    local pos = vim.api.nvim_win_get_position(self.winnr)
    local dim = {
      row = pos[1] - self.opts.padding.top,
      col = pos[2] - self.opts.padding.left,
      width = vim.api.nvim_win_get_width(self.winnr) + self.opts.padding.left + self.opts.padding.right,
      height = vim.api.nvim_win_get_height(self.winnr) + self.opts.padding.top + self.opts.padding.bottom,
    }
    ensure_scroll_options(self.winnr)

    local buf_h = text_height(self.winnr)

    if self.opts.autohide and dim.height >= buf_h then
      self:hide()
      return
    elseif not self.visible then
      self:show()
    end

    if not (vim.api.nvim_win_is_valid(self.bar.winnr) and vim.api.nvim_win_is_valid(self.thumb.winnr)) then
      self:hide()
      self:show()
    end

    local zindex = vim.api.nvim_win_get_config(self.winnr).zindex or 50
    util.win_apply_config(self.bar.winnr, {
      height = dim.height,
      width = 1,
      col = dim.col + dim.width - 1,
      row = dim.row,
      zindex = zindex + 1,
    })

    local thumb_h = math.max(1, math.floor(dim.height * dim.height / buf_h + 0.5))
    local denom = math.max(1, scroll_limit(self.winnr))
    local pct = clamp(scroll_offset(self.winnr) / denom, 0, 1)
    local offset = math.floor(pct * (dim.height - thumb_h) + 0.5)

    util.win_apply_config(self.thumb.winnr, {
      width = 1,
      height = thumb_h,
      row = dim.row + offset,
      col = dim.col + dim.width - 1,
      zindex = zindex + 2,
    })
  end
end

local function patch_docs_scroll()
  local docs = require("noice.lsp.docs")

  if docs._ray_hover_scroll_patched then
    return
  end

  docs._ray_hover_scroll_patched = true

  local original_scroll = docs.scroll

  function docs.scroll(delta)
    local msg = docs._messages and docs._messages.hover
    local win = msg and msg:win()

    if win then
      vim.defer_fn(function()
        if not vim.api.nvim_win_is_valid(win) then
          return
        end

        ensure_scroll_options(win)
        scroll_to(win, scroll_offset(win) + delta)
        layout.refresh()
      end, 0)
      return true
    end

    return original_scroll(delta)
  end
end

local function patch_show()
  local view = require("noice.view.nui")

  if view._ray_hover_show_patched then
    return
  end

  view._ray_hover_show_patched = true

  local show = view.show

  function view:show()
    local sig = hover.is(self) and self:content() or nil
    local changed = sig and self._ray_hover_sig ~= sig

    self._ray_hover_sig = sig or self._ray_hover_sig

    show(self)

    if not hover.is(self) then
      return
    end

    local win = self._nui and self._nui.winid

    if not (win and vim.api.nvim_win_is_valid(win)) then
      return
    end

    ensure_scroll_options(win)

    if changed then
      clamping = true
      vim.api.nvim_win_call(win, function()
        vim.fn.winrestview({
          topline = 1,
          topfill = 0,
          lnum = 1,
          col = 0,
          curswant = 0,
          skipcol = 0,
          leftcol = 0,
        })
      end)
      clamping = false
      layout.refresh(self)
    else
      clamp_win(win)
    end
  end
end

local function watch_native_scroll()
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = vim.api.nvim_create_augroup("RayNoiceHoverScroll", { clear = true }),
    callback = function(args)
      local view = layout.current()
      local win = view and view._nui and view._nui.winid

      if win and tostring(win) == args.match then
        vim.schedule(function()
          clamp_win(win)
        end)
      end
    end,
  })
end

function M.patch()
  patch_bar()
  patch_docs_scroll()
  patch_show()
  watch_native_scroll()
end

return M
