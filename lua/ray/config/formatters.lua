vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = "1"

local M = {}

M.prettier_tools = { "prettierd", "prettier" }
M.prettier_formatters = { "prettierd", "prettier", stop_after_first = true }

return M
