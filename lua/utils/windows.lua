local M = {}

-- Listed normal file buffers are candidates for user work. Plugin, terminal,
-- help, prompt, and unlisted scratch buffers are excluded.
function M.is_file(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" and vim.bo[bufnr].buflisted
end

-- A normal window is part of the editor layout. Floating windows, like Neo-tree
-- filters and picker inputs, should not drive buffer lifecycle decisions.
function M.is_normal_win(win)
  return win ~= 0 and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ""
end

-- Empty unnamed file buffers are reusable placeholders only when they were
-- never edited and contain exactly the initial blank line.
function M.is_empty_unnamed_file(bufnr)
  if
    not vim.api.nvim_buf_is_valid(bufnr)
    or not vim.api.nvim_buf_is_loaded(bufnr)
    or vim.bo[bufnr].buftype ~= ""
    or vim.api.nvim_buf_get_name(bufnr) ~= ""
    or vim.bo[bufnr].modified
  then
    return false
  end

  return vim.api.nvim_buf_line_count(bufnr) == 1 and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""
end

-- Work files are regular listed buffers that keep normal buffer lifecycle.
-- Temporary editor buffers can still be real files, but they opt into
-- bufhidden cleanup and should be deleted without closing their window.
function M.is_work_file(bufnr)
  return M.is_file(bufnr) and vim.api.nvim_buf_get_name(bufnr) ~= "" and vim.bo[bufnr].bufhidden == ""
end

-- A work window is both a normal editor window and currently showing a work file.
-- This guards against sidebars/floats triggering file-buffer cleanup logic.
function M.is_work_win(win)
  return M.is_normal_win(win) and M.is_work_file(vim.api.nvim_win_get_buf(win))
end

return M
