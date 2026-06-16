local M = {}

local function format_git_summary(args)
  local summary = vim.b[args.buf].minigit_summary
  local head = summary.head_name

  if head == nil then
    return
  end

  if head == "HEAD" then
    head = summary.head:sub(1, 7)
  end

  local in_progress = summary.in_progress or ""

  if in_progress ~= "" then
    head = head .. "|" .. in_progress
  end

  vim.b[args.buf].minigit_summary_string = head
end

function M.setup()
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniGitUpdated",
    callback = format_git_summary,
  })

  require("mini.git").setup()
end

return M
