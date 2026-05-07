local M = {}

function M.source_column(items, get_item)
  local width = 0
  get_item = get_item or function(item)
    return item
  end

  for _, item in ipairs(items) do
    width = math.max(width, vim.fn.strdisplaywidth(get_item(item).title_text))
  end

  return width + 2
end

function M.line(item, source_col)
  local padding = math.max(source_col - vim.fn.strdisplaywidth(item.title_text), 1)

  return item.title_text .. string.rep(" ", padding) .. item.source_text
end

return M
