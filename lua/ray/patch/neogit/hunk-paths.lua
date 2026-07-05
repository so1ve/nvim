local hacks = require("ray.patch.hacks")

local M = {}

local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

local function is_absolute_path(path)
  return path:match("^%a:[/\\]") ~= nil or path:sub(1, 1) == "/" or path:sub(1, 2) == "\\\\"
end

local function repo_relative_path(path)
  if not is_absolute_path(path) then
    return path:gsub("\\", "/")
  end

  local ok, git = pcall(require, "neogit.lib.git")
  local root = ok and git.repo and git.repo.worktree_root
  local relative = root and vim.fs.relpath(vim.fs.normalize(root), vim.fs.normalize(path)) or nil

  return (relative or path):gsub("\\", "/")
end

local function normalize_patch_header(patch, path)
  patch = patch:gsub("^%-%-%- a/[^\r\n]+", function()
    return "--- a/" .. path
  end, 1)

  local normalized = patch:gsub("\n%+%+%+ b/[^\r\n]+", function()
    return "\n+++ b/" .. path
  end, 1)

  return normalized
end

function M.patch()
  if not is_windows() then
    return
  end

  hacks.on_module("neogit.lib.git.index", function(index)
    hacks.wrap(index, "neogit_issue_1957_windows_hunk_paths", "generate_patch", function(generate_patch)
      return function(hunk, opts)
        local patch = generate_patch(hunk, opts)
        local path = repo_relative_path(hunk.file)

        -- NeogitOrg/neogit#1957: Windows hunk patches can contain absolute
        -- paths in a/<path> and b/<path> headers. Git applies hunks against the
        -- index by repository-relative path, so normalize only the headers.
        return normalize_patch_header(patch, path)
      end
    end)
  end)
end

return M
