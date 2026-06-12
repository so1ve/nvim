local M = {}

function M.patch()
  local hacks = require("utils.hacks")
  local ignore = require("config.ignore")

  hacks.on_module("fff.fuzzy", function(fuzzy)
    for _, name in ipairs({ "fuzzy_search_files", "fuzzy_search_directories", "fuzzy_search_mixed", "live_grep" }) do
      if type(fuzzy[name]) == "function" then
        hacks.wrap(fuzzy, "ignore." .. name, name, function(original)
          return function(...)
            return ignore.filter_fff_result(original(...))
          end
        end)
      end
    end
  end)
end

return M
