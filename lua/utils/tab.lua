local M = {}

local function next_sidekick_action(edit, bufnr, cursor)
  if edit.buf ~= bufnr then
    return "jump"
  end

  local cursor_row = cursor[1] - 1
  local from_row = edit.from[1]
  local to_row = edit.to[1]
  local start_row = math.min(from_row, to_row)
  local end_row = math.max(from_row, to_row)

  return cursor_row >= start_row and cursor_row <= end_row and "apply" or "jump"
end

local function accept_copilot_suggestion()
  local suggestion = require("copilot.suggestion")

  if not suggestion.is_visible() then
    return false
  end

  suggestion.accept()

  return true
end

---@param cmp blink.cmp.API
---@return boolean?
function M.blink_cmp(cmp)
  if cmp.is_menu_visible() then
    return cmp.select_and_accept()
  end

  return accept_copilot_suggestion()
end

---@return boolean
function M.sidekick_nes_jump_or_apply()
  local nes = require("sidekick.nes")

  if not nes.have() then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local edit = nes.get(bufnr)[1]
  local action = next_sidekick_action(edit, bufnr, vim.api.nvim_win_get_cursor(0))

  if action == "apply" then
    return nes.apply()
  end

  return nes.jump() or nes.apply()
end

return M
