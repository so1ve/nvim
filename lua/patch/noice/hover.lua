local M = {}

function M.is(view)
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

function M.update_bar(view)
  if view and view._scroll then
    view._scroll._ray_hover = true
    view._scroll:update()
  end
end

return M
