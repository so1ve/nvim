local M = {}

local ignored = {}
local root = nil

local function notify_changed()
  vim.api.nvim_exec_autocmds("User", { pattern = "RayGitIgnoreCacheUpdated", modeline = false })
end

local function clean(path)
  return vim.fs.normalize(tostring(path or "")):gsub("\\", "/"):gsub("/+$", "")
end

local function rel(path)
  path = clean(path)
  if root and path:sub(1, #root + 1) == root .. "/" then
    path = path:sub(#root + 2)
  end
  return path:gsub("^%./", "")
end

function M.refresh()
  local git_root = vim.fs.root(vim.fn.getcwd(), ".git")
  if not git_root then
    root = nil
    ignored = {}
    notify_changed()
    return
  end

  root = clean(git_root)

  vim.system(
    { "git", "-C", root, "ls-files", "--ignored", "--others", "--exclude-standard", "--directory", "-z" },
    { text = true },
    vim.schedule_wrap(function(result)
      if root ~= clean(git_root) then
        return
      end

      ignored = { [".git"] = true }
      if result.code == 0 then
        for path in tostring(result.stdout or ""):gmatch("[^%z]+") do
          ignored[rel(path)] = true
        end
      else
        ignored = {}
      end
      notify_changed()
    end)
  )
end

function M.is_ignored(path)
  path = rel(path)
  while path and path ~= "" do
    if ignored[path] then
      return true
    end
    path = path:match("(.+)/[^/]+$")
  end

  return false
end

function M.setup()
  M.refresh()
  vim.api.nvim_create_autocmd("DirChanged", { callback = M.refresh })
end

return M
