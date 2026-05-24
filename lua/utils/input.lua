local M = {}

local function input_width(text)
  return math.max(24, vim.api.nvim_strwidth(text) + 10)
end

function M.relative(opts, on_confirm)
  local default = tostring(opts.default or "")
  local win = vim.tbl_extend("force", {
    relative = "cursor",
    row = -3,
    col = 0,
    width = input_width(default),
    title_pos = "left",
  }, opts.win or {})

  vim.ui.input(vim.tbl_extend("force", opts, { win = win }), on_confirm)
end

return M
