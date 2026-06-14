local M = {}

local function cursor_in_edit(edit, bufnr, cursor)
  if edit.buf ~= bufnr then
    return false
  end

  local row = cursor[1] - 1
  local from = edit.from[1]
  local to = edit.to[1]

  if from > to then
    from, to = to, from
  end

  return row >= from and row <= to
end

---@return boolean
function M.accept_ai()
  local suggestion = require("copilot.suggestion")

  if not suggestion.is_visible() then
    return false
  end

  suggestion.accept()

  return true
end

---@return boolean
function M.sidekick_nes_jump_or_apply()
  local nes = require("sidekick.nes")

  if not nes.have() then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local edit = nes.get(bufnr)[1]
  if cursor_in_edit(edit, bufnr, vim.api.nvim_win_get_cursor(0)) then
    return nes.apply()
  end

  return nes.jump() or nes.apply()
end

return M
