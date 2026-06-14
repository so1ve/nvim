-- Noice markdown visual width patch.
-- Purpose: size hover layout from cached rendered markdown width instead of raw
-- source width. Link parsing/rendering lives in `patch.noice.markdown-links`.

local M = {}
local hacks = require("ray.utils.hacks")

local function line_width(line)
  local content = line:content()

  if line._ray_markdown_visual_width and line._ray_markdown_width_source == content then
    return line._ray_markdown_visual_width
  end

  return line:width()
end

function M.fix_layout(view, layout)
  if not (layout.size and type(layout.size.width) == "number" and layout.size.width > 0) then
    return layout
  end

  if not (view._opts.type == "popup" and view._opts.win_options and view._opts.win_options.wrap) then
    return layout
  end

  local view_width = view:width()

  if layout.size.width >= view_width then
    return layout
  end

  local height = 0

  for _, msg in ipairs(view._messages or {}) do
    for _, line in ipairs(msg._lines or {}) do
      height = height + math.max(1, math.ceil(line_width(line) / layout.size.width))
    end
  end

  return require("noice.util").nui.get_layout({ width = view_width, height = height }, view._opts)
end

function M.patch()
  local block = require("noice.text.block")

  hacks.wrap(block, "noice.markdown.block.width", "width", function()
    -- Prefer cached visual widths for lines produced by the link-aware markdown
    -- formatter; fall back to Noice's upstream width calculation otherwise.
    return function(self)
      local ret = 0

      for _, line in ipairs(self._lines) do
        ret = math.max(ret, line_width(line))
      end

      return ret
    end
  end)
end

return M
