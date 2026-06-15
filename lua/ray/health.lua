local M = {}

local executables = {
  "git",
  "rg",
  "fd",
  "tree-sitter",
  "gh",
  "node",
  "python",
}

function M.check()
  vim.health.start("Ray's Neovim config")

  for _, name in ipairs(executables) do
    if vim.fn.executable(name) == 1 then
      vim.health.ok(name .. " is available")
    else
      vim.health.error((name .. " is missing"))
    end
  end

  if vim.fn.has("win32") == 1 then
    if vim.fn.executable("pwsh") == 1 then
      vim.health.ok("PowerShell shell is available")
    else
      vim.health.error("PowerShell is missing; terminal commands may not work as configured")
    end
  end
end

return M
