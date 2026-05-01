return function(message, level, title)
  vim.notify(message, level or vim.log.levels.INFO, { title = title or "Neovim" })
end
