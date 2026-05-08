local M = {}

function M.is_file(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" and vim.bo[bufnr].buflisted
end

function M.is_normal_win(win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ""
end

function M.is_dashboard(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "snacks_dashboard"
end

function M.is_work_file(bufnr)
  return M.is_file(bufnr) and not M.is_dashboard(bufnr)
end

function M.is_work_win(win)
  return M.is_normal_win(win) and M.is_work_file(vim.api.nvim_win_get_buf(win))
end

function M.has_many_files(wins)
  local file_win_count = 0

  for _, win in ipairs(wins) do
    if M.is_work_win(win) then
      file_win_count = file_win_count + 1

      if file_win_count > 1 then
        return true
      end
    end
  end

  return false
end

return M
