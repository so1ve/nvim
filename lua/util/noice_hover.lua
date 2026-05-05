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

local function is_hover(view)
  if view._opts.view ~= "hover" then
    return false
  end

  for _, msg in ipairs(view._messages or {}) do
    if msg.event == "lsp" and msg.kind == "hover" then
      return true
    end
  end

  return false
end

local function cursor(view)
  local cur = vim.api.nvim_get_current_win()
  local hover_win = view._nui and view._nui.winid

  -- Once the hover exists, the current window may become the hover window during
  -- scroll/documentation interactions. Keep using the source code window for
  -- screenrow()/screencol(), otherwise the popup starts positioning itself.
  if cur ~= hover_win and vim.api.nvim_win_is_valid(cur) then
    view._ray_hover_src_win = cur
  end

  local win = view._ray_hover_src_win
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return 0, -1
  end

  -- nvim_win_call returns only the callback's first value, so return a table
  -- instead of `row, col`; otherwise screencol() is silently dropped.
  local pos = vim.api.nvim_win_call(win, function()
    local sr = vim.fn.screenrow()
    local sc = vim.fn.screencol()

    return {
      row = sr or 0,
      col = sc and sc - 1 or -1,
    }
  end)

  return pos.row, pos.col
end

local function place(view, layout)
  local size = layout.size

  if not (size and type(size.width) == "number" and type(size.height) == "number") then
    return layout
  end

  local cols = vim.o.columns
  local rows = vim.o.lines
  local pad = 2
  -- Approximate the extra cells used by the rounded border/padding. The actual
  -- NUI border window is separate, so leave a little space at the screen edges.
  local bw = 2
  local bh = 1
  local w = math.min(size.width, math.max(1, cols - (pad + bw) * 2))
  local h = size.height
  local sr, sc = cursor(view)

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

  local left = pad + bw
  local right = math.max(left, cols - w - bw - pad)
  local mid = (cols - 1) / 2
  local drift = math.max(12, math.min(30, math.floor(cols * 0.15)))
  local pull = 0.25
  -- Horizontally, bias toward editor center. The cursor only adds a small pull,
  -- so wide hovers near a left-indented symbol do not snap back to the left.
  local col = round(mid + clamp(sc - mid, -drift, drift) * pull - w / 2)

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

    if not (active and is_hover(active) and active._nui and active:is_mounted()) then
      return
    end

    pcall(function()
      active:update_layout()

      -- NuiView:update_layout() only moves/resizes the popup. Noice normally
      -- refreshes its scrollbar from NuiView:show(), so do that explicitly for
      -- our scroll-driven relayout path.
      if active._scroll then
        active._scroll:update()
      end
    end)

    -- Satellite tracks ordinary editor windows, not Noice floating windows. A
    -- float relayout can leave its overlay scrollbar stale, so ask Satellite to
    -- recompute if it is already available.
    pcall(function()
      require("satellite.view").schedule_refresh()
    end)
  end)
end

local function watch_scroll()
  -- Scrolling changes screenrow()/screencol() without necessarily causing Noice
  -- to rebuild the hover, so schedule a debounced layout refresh.
  vim.api.nvim_create_autocmd({ "WinScrolled", "WinResized", "VimResized" }, {
    group = vim.api.nvim_create_augroup("RayNoiceHoverLayout", { clear = true }),
    callback = relayout,
  })
end

function M.patch()
  local view = require("noice.view.nui")

  if view._ray_hover_layout_patched then
    return
  end

  view._ray_hover_layout_patched = true

  local get_layout = view.get_layout

  function view:get_layout()
    local layout = get_layout(self)

    if not is_hover(self) then
      return layout
    end

    -- Noice/NUI can do cursor-relative row+col or editor-relative row+col, but
    -- not cursor-relative row with center-biased editor-relative col. Patch the
    -- final computed layout so we can mix those behaviors only for LSP hover.
    active = self
    return place(self, layout)
  end

  watch_scroll()
end

return M
