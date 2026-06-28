-- Tab-key completion behavior that composes completion, Copilot, and Sidekick.

local M = {}

local ignore_key = vim.api.nvim_replace_termcodes("<Ignore>", true, false, true)

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

---@param cmp table
---@return string|false
function M.select_and_accept(cmp)
  if not cmp.select_and_accept() then
    return false
  end

  return ignore_key
end

---@return string|false
function M.accept_ai()
  local suggestion = require("copilot.suggestion")

  if not suggestion.is_visible() then
    return false
  end

  suggestion.accept()

  return ignore_key
end

---@return string|false
function M.sidekick_nes_jump_or_apply()
  local nes = require("sidekick.nes")

  if not nes.have() then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local edit = nes.get(bufnr)[1]
  if cursor_in_edit(edit, bufnr, vim.api.nvim_win_get_cursor(0)) then
    return nes.apply() and ignore_key or false
  end

  return (nes.jump() or nes.apply()) and ignore_key or false
end

return M
