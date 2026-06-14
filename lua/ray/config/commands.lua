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

vim.api.nvim_create_user_command("RayRunShell", function(opts)
  local command = opts.args
  if command == "" then
    command = vim.fn.input("Shell command: ", "", "shellcmd")
  end

  if command == "" then
    return
  end

  local bufname = vim.api.nvim_buf_get_name(0)
  local root = vim.fs.root(bufname ~= "" and bufname or vim.fn.getcwd(0), { ".git" }) or vim.fn.getcwd(0)

  Snacks.terminal.open(vim.fn.expandcmd(command:gsub("%$root", root)), {
    auto_close = false,
    count = 3,
    cwd = root,
    win = { position = "bottom", height = 12 },
  })
end, { complete = "shellcmd", desc = "Run shell command", nargs = "*" })
