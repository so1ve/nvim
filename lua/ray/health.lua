local M = {}

local function executable(name, note)
  if vim.fn.executable(name) == 1 then
    vim.health.ok(name .. " is available")

    return
  end

  local message = name .. " is missing"

  if note then
    message = message .. "; " .. note
  end

  vim.health.error(message)
end

function M.check()
  vim.health.start("Ray's Neovim config")

  if vim.fn.has("nvim-0.12") == 1 then
    vim.health.ok("Neovim >= 0.12 detected")
  else
    vim.health.error("Neovim >= 0.12 is required")
  end

  executable("git", "lazy.nvim needs Git to install plugins")
  executable("rg", "grep workflows use ripgrep")
  executable("fd", "file finding workflows use fd")
  executable("tree-sitter", "parser workflows need tree-sitter-cli")
  executable("gh", "GitHub CLI is used for various GitHub workflows")
  executable("node", "TypeScript, ESLint, Prettier, and markdown tools need Node.js")
  executable("python", "Python LSP, DAP, and test adapters need Python")

  if vim.fn.has("win32") == 1 then
    if vim.fn.executable("pwsh") == 1 or vim.fn.executable("powershell") == 1 then
      vim.health.ok("PowerShell shell is available")
    else
      vim.health.error("PowerShell is missing; terminal commands may not work as configured")
    end
  end
end

return M
