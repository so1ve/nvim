local M = {}

local is_windows = vim.fn.has("win32") == 1

M.shell = {
  shell = nil,
  flag = nil,
  shellcmdflag = nil,
}

if is_windows then
  M.shell = {
    shell = "pwsh",
    flag = "-NoLogo",
    shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command",
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
end

return M
