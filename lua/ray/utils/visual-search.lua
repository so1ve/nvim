local M = {}

local function selection_text()
  local mode = vim.fn.mode()
  local from = vim.fn.getpos("v")
  local to = vim.fn.getpos(".")

  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return nil
  end

  if from[2] == 0 or to[2] == 0 or from[2] ~= to[2] then
    return nil
  end

  local chunks = vim.fn.getregion(from, to, { type = mode })

  if #chunks ~= 1 or chunks[1] == "" then
    return nil
  end

  return chunks[1]
end

function M.pattern_from_visual_selection()
  local text = selection_text()

  if not text then
    return nil
  end

  return [[\V]] .. vim.fn.escape(text, [[\]])
end

function M.search_keys(direction)
  local pattern = M.pattern_from_visual_selection()

  if not pattern then
    return direction == "backward" and "?" or "/"
  end

  vim.fn.setreg("/", pattern)
  vim.fn.histadd("/", pattern)
  vim.v.searchforward = direction == "backward" and 0 or 1

  return direction == "backward" and "<Esc>2n" or "<Esc>n"
end

return M
