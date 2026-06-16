vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "FocusGained", "TermClose", "TermLeave" }, {
  callback = function()
    if vim.bo.buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "css", "scss", "html", "vue", "svelte" },
  callback = function()
    vim.opt_local.iskeyword:append("-")
  end,
})
