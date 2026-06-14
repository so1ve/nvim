-- Shared Noice hover helpers.
-- Purpose: centralize what counts as our LSP hover view.
-- Implementation: `is()` inspects Noice view metadata for LSP hover messages;
-- other patches use this to avoid touching non-hover Noice popups.

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

return M
