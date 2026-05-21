local M = {}

local is_windows = vim.fn.has("win32") == 1

M.shell = {
  shell = nil,
  flag = nil,
  shellcmdflag = nil,
  shellpipe = nil,
  shellredir = nil,
}

if is_windows then
  M.shell = {
    shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
    flag = "-NoLogo",
    shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command",
    shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
  }
end

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
