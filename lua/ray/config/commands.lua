vim.api.nvim_create_user_command("RayHealth", function()
  vim.cmd.checkhealth("ray")
end, { desc = "Run Ray's Neovim health checks" })

vim.api.nvim_create_user_command("RayFormatToggle", function(args)
  if args.bang then
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    vim.notify("Global format-on-save: " .. (vim.g.disable_autoformat and "disabled" or "enabled"))

    return
  end

  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify("Buffer format-on-save: " .. (vim.b.disable_autoformat and "disabled" or "enabled"))
end, { bang = true, desc = "Toggle format-on-save for buffer, or globally with !" })

vim.api.nvim_create_user_command("RayTheme", function(args)
  local themes = require("ray.config.themes")

  if args.args == "" then
    themes.select()

    return
  end

  themes.save(themes.apply(args.args))
end, {
  nargs = "?",
  complete = function(arglead)
    return require("ray.config.themes").complete(arglead)
  end,
  desc = "Switch colorscheme",
})

vim.api.nvim_create_user_command("TSReset", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.treesitter.stop(bufnr)
  vim.defer_fn(function()
    vim.treesitter.start(bufnr)
    vim.notify("Treesitter reset for current buffer", vim.log.levels.INFO)
  end, 100)
end, { desc = "Reset treesitter for current buffer" })
