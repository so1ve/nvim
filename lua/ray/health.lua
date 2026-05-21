local M = {}

local function executable(name, required, note)
  if vim.fn.executable(name) == 1 then
    vim.health.ok(name .. " is available")

    return
  end

  local message = name .. " is missing"

  if note then
    message = message .. "; " .. note
  end

  if required then
    vim.health.error(message)
  else
    vim.health.warn(message)
  end
end

function M.check()
  vim.health.start("Ray's Neovim config")

  if vim.fn.has("nvim-0.11") == 1 then
    vim.health.ok("Neovim >= 0.11 detected")
  elseif vim.fn.has("nvim-0.10") == 1 then
    vim.health.warn("Neovim 0.10 detected; this config works best on 0.11+")
  else
    vim.health.error("Neovim >= 0.10 is required")
  end

  executable("git", true, "lazy.nvim needs Git to install plugins")
  executable("rg", true, "Snacks picker and grep workflows use ripgrep")
  executable("fd", false, "file finding is faster with fd")
  executable("tree-sitter", false, "some parser workflows may need tree-sitter-cli")
  executable("lazygit", false, "<leader>gg uses lazygit")
  executable("node", false, "TypeScript, ESLint, Prettier, and markdown tools need Node.js")
  executable("python", false, "Python LSP, DAP, and test adapters may need Python")

  if vim.fn.has("win32") == 1 then
    if vim.fn.executable("pwsh") == 1 or vim.fn.executable("powershell") == 1 then
      vim.health.ok("PowerShell shell is available")
    else
      vim.health.warn("PowerShell is missing; terminal commands may not work as configured")
    end
  end
end

return M
