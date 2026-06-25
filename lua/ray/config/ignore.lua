local M = {}

M.names = { ".git", ".svn", ".hg", "CVS", ".DS_Store", "Thumbs.db", "thumbs.db" }
M.patterns = { "*.tsbuildinfo" }

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

function M.filter_fff_result(result)
  if type(result) ~= "table" or type(result.items) ~= "table" then
    return result
  end

  local items = {}
  local scores = result.scores and {} or nil

  for index, item in ipairs(result.items) do
    if not M.is_ignored(item.relative_path or item.file or item.name) then
      items[#items + 1] = item
      if scores then
        scores[#scores + 1] = result.scores[index]
      end
    end
  end

  result.items = items
  if scores then
    result.scores = scores
  end

  return result
end

return M
