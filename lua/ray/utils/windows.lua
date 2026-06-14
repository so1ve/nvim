local M = {}

-- A normal window is part of the editor layout. Floating windows, like Neo-tree
-- filters and picker inputs, should not drive buffer lifecycle decisions.
function M.is_normal_win(win)
  return win ~= 0 and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ""
end

-- Work files are regular listed buffers that keep normal buffer lifecycle.
-- Temporary editor buffers can still be real files, but they opt into
-- bufhidden cleanup and should be deleted without closing their window.
function M.is_work_file(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.bo[bufnr].buftype == ""
    and vim.bo[bufnr].buflisted
    and vim.api.nvim_buf_get_name(bufnr) ~= ""
    and vim.bo[bufnr].bufhidden == ""
end

return M
