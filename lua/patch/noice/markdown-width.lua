-- Noice markdown visual width patch.
-- Purpose: size hover layout from rendered markdown width instead of raw source
-- width. Link parsing/rendering lives in `patch.noice.markdown-links`; this
-- module only consumes the cached visual-width metadata it produces.

local M = {}
local hacks = require("utils.hacks")

function M.width(text, references)
  local content = require("patch.noice.markdown-links").visual_content(text, references)

  return vim.api.nvim_strwidth(content)
end

function M.line_width(line)
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
      height = height + math.max(1, math.ceil(M.line_width(line) / layout.size.width))
    end
  end

  return require("noice.util").nui.get_layout({ width = view_width, height = height }, view._opts)
end

function M.patch()
  local block = require("noice.text.block")

  hacks.wrap(block, "noice.markdown.block.width", "width", function(width)
    -- Prefer cached visual widths for lines produced by the link-aware markdown
    -- formatter; fall back to Noice's upstream width calculation otherwise.
    return function(self)
      local has_markdown_width = false
      local ret = 0

      for _, line in ipairs(self._lines or {}) do
        if line._ray_markdown_visual_width then
          has_markdown_width = true
        end

        ret = math.max(ret, M.line_width(line))
      end

      if has_markdown_width then
        return ret
      end

      return width(self)
    end
  end)
end

return M
