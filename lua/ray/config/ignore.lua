local M = {}

M.names = {
  ".git",
  ".svn",
  ".hg",
  "CVS",
  ".DS_Store",
  "Thumbs.db",
  "thumbs.db",
  ".cache",
  ".direnv",
  ".next",
  ".nuxt",
  ".parcel-cache",
  ".pytest_cache",
  ".ruff_cache",
  ".svelte-kit",
  ".turbo",
  ".venv",
  ".vercel",
  "__pycache__",
  "bower_components",
  "coverage",
  "out",
  "node_modules",
  "target",
  "dist",
  "build",
  "venv",
}
M.patterns = { "*.tsbuildinfo", "*.pyc", "*.pyo" }

local function glob_to_lua(glob)
  return "^" .. glob:gsub("([^%w%*%?])", "%%%1"):gsub("%*", ".*"):gsub("%?", ".") .. "$"
end

function M.is_ignored(path)
  path = tostring(path or ""):gsub("\\", "/")
  local name = path:match("[^/]+$") or path

  for part in path:gmatch("[^/]+") do
    if vim.tbl_contains(M.names, part) then
      return true
    end
  end

  for _, pattern in ipairs(M.patterns) do
    if name:find(glob_to_lua(pattern)) then
      return true
    end
  end

  return false
end

return M
