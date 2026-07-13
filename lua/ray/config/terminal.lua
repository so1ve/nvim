local M = {}

M.shell = vim.fn.has("win32") == 1 and {
  shell = "pwsh -NoLogo",
  shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command",
  shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
  shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
} or {}

function M.setup()
  if not M.shell.shell then
    return
  end

  vim.opt.shell = M.shell.shell
  vim.opt.shellcmdflag = M.shell.shellcmdflag
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
  vim.opt.shellpipe = M.shell.shellpipe
  vim.opt.shellredir = M.shell.shellredir
end

return M
