-- Keep Neo-tree windows free of sign columns
vim.wo.signcolumn = "no"

-- Re-apply when new windows open on this buffer
vim.api.nvim_create_autocmd("BufWinEnter", {
  buffer = 0,
  callback = function()
    vim.wo.signcolumn = "no"
  end,
})
