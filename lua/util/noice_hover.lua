local M = {}

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

local function place(layout)
  local size = layout.size

  if not (size and type(size.width) == "number" and type(size.height) == "number") then
    return layout
  end

  local cols = vim.o.columns
  local rows = vim.o.lines
  local pad = 2
  local bw = 2
  local bh = 1
  local w = math.min(size.width, math.max(1, cols - (pad + bw) * 2))
  local h = size.height
  local sr = vim.fn.screenrow()
  local sc = vim.fn.screencol() - 1

  if sr <= 0 or sc < 0 then
    return layout
  end

  local top = pad + bh
  local bot = math.max(top, rows - h - bh - pad)
  local down = sr + 1
  local up = sr - h - bh * 2
  local row = down + h + bh <= rows - pad and down or up

  local left = pad + bw
  local right = math.max(left, cols - w - bw - pad)
  local mid = (cols - 1) / 2
  local drift = math.max(12, math.min(30, math.floor(cols * 0.15)))
  local min_mid = math.max(mid - drift, left + w / 2)
  local max_mid = math.min(mid + drift, right + w / 2)

  if max_mid < min_mid then
    min_mid = left + w / 2
    max_mid = right + w / 2
  end

  local col = round(clamp(sc, min_mid, max_mid) - w / 2)

  layout.relative = "editor"
  layout.anchor = "NW"
  layout.position = {
    row = clamp(row, top, bot),
    col = clamp(col, left, right),
  }
  layout.size.width = w

  return layout
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

    return is_hover(self) and place(layout) or layout
  end
end

return M
