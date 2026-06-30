local hacks = require("ray.patch.hacks")
local ignore = require("ray.config.ignore")

local M = {}

local function filter_result(result)
  if type(result) ~= "table" or type(result.items) ~= "table" then
    return result
  end

  local items = {}
  local scores = result.scores and {} or nil

  for index, item in ipairs(result.items) do
    if not ignore.is_ignored(item.relative_path or item.file or item.name) then
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

function M.patch()
  hacks.on_module("fff.fuzzy", function(fuzzy)
    for _, name in ipairs({ "fuzzy_search_files", "fuzzy_search_directories", "fuzzy_search_mixed", "live_grep" }) do
      if type(fuzzy[name]) == "function" then
        hacks.wrap(fuzzy, "ignore." .. name, name, function(original)
          return function(...)
            return filter_result(original(...))
          end
        end)
      end
    end
  end)
end

return M
