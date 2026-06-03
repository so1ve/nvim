local hacks = require("utils.hacks")

local M = {}

local function highlight_current_match(bufnr, location, namespace)
  if not location.line then
    return
  end

  local row = math.max(1, math.min(location.line, vim.api.nvim_buf_line_count(bufnr))) - 1
  local col = location.col and location.col - 1

  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, namespace, { row, 0 }, { row + 1, 0 }, { details = true })) do
    local details = assert(mark[4])

    if details.line_hl_group == "CursorLine" then
      vim.api.nvim_buf_set_extmark(bufnr, namespace, row, mark[3], {
        id = mark[1],
        number_hl_group = details.number_hl_group,
        priority = details.priority,
      })
    end

    if
      details.hl_group == "IncSearch"
      and (location.fuzzy_match_ranges or not col or (mark[3] <= col and col < details.end_col))
    then
      vim.api.nvim_buf_set_extmark(bufnr, namespace, row, mark[3], {
        id = mark[1],
        end_col = details.end_col,
        hl_group = "FFFPreviewCurrentMatch",
        priority = details.priority,
      })
    end
  end
end

function M.patch()
  hacks.on_module("fff.location_utils", function(location_utils)
    hacks.wrap(location_utils, "fff.preview_match", "highlight_grep_matches", function(original)
      return function(bufnr, location, namespace)
        local result = original(bufnr, location, namespace)

        highlight_current_match(bufnr, location, namespace)

        return result
      end
    end)
  end)
end

return M
