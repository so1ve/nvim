local M = {}

local root
local ignored = {}

local function changed()
  vim.api.nvim_exec_autocmds("User", { pattern = "RayGitIgnoreCacheUpdated" })
end

local function normalize(path)
  return vim.fs.normalize(path):gsub("\\", "/"):gsub("/+$", "")
end

local function relative(path)
  path = normalize(path)
  if root and path:sub(1, #root + 1) == root .. "/" then
    return path:sub(#root + 2)
  end
  return path:gsub("^%./", "")
end

function M.refresh()
  local git_root = vim.fs.root(vim.fn.getcwd(), ".git")
  root = git_root and normalize(git_root)

  if not root then
    ignored = {}
    changed()
    return
  end

  local refresh_root = root
  vim.system(
    { "git", "-C", root, "ls-files", "--ignored", "--others", "--exclude-standard", "--directory", "-z" },
    {
      text = true,
    },
    vim.schedule_wrap(function(result)
      if root ~= refresh_root then
        return
      end

      ignored = result.code == 0 and { [".git"] = true } or {}
      for path in (result.stdout or ""):gmatch("[^%z]+") do
        ignored[relative(path)] = true
      end
      changed()
    end)
  )
end

function M.is_ignored(path)
  path = relative(path)
  while path ~= "" do
    if ignored[path] then
      return true
    end
    path = path:match("(.+)/[^/]+$") or ""
  end

  return false
end

function M.setup()
  M.refresh()
  vim.api.nvim_create_autocmd("DirChanged", { callback = M.refresh })
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { ".gitignore", "*/.gitignore", ".git/info/exclude", "*/.git/info/exclude" },
    callback = M.refresh,
  })
end

return M
