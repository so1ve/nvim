return function(opts)
  local command = opts.args
  if command == "" then
    command = vim.fn.input("Shell command: ", "", "shellcmd")
  end

  if command == "" then
    return
  end

  local bufname = vim.api.nvim_buf_get_name(0)
  local root = vim.fs.root(bufname ~= "" and bufname or vim.fn.getcwd(0), { ".git" }) or vim.fn.getcwd(0)
  local win = opts.smods.vertical and { position = "right", width = 0.45 } or { position = "bottom", height = 12 }

  if opts.smods.tab >= 0 then
    vim.cmd.tabnew()
  end

  return Snacks.terminal.open(vim.fn.expandcmd(command:gsub("%$root", root)), {
    auto_close = false,
    count = 3,
    cwd = root,
    win = win,
  })
end
