vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Reload files changed outside Neovim",
  callback = function()
    if vim.bo.buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "css", "scss", "html", "vue", "svelte" },
  desc = "Treat hyphenated web identifiers as one keyword",
  callback = function()
    vim.opt_local.iskeyword:append("-")
  end,
})
