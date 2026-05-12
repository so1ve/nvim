local M = {}

local function command_span(cmdline)
  return cmdline:find("^%s*(%S+)")
end

local function command_accepts_args(command)
  local normalized_command = command:gsub("!$", "")
  local command_info = vim.api.nvim_get_commands({ builtin = false })[normalized_command]

  return command_info ~= nil and command_info.nargs ~= "0"
end

local function is_protected_prefix_boundary()
  if vim.fn.getcmdtype() ~= ":" then
    return false
  end

  local cmdline = vim.fn.getcmdline()
  local cmdpos = vim.fn.getcmdpos()
  local _, command_end, command = command_span(cmdline)

  if command == nil or not command_accepts_args(command) then
    return false
  end

  local first_arg_start = cmdline:find("%S", command_end + 1)
  local prefix_boundary = first_arg_start or #cmdline + 1

  if cmdpos <= command_end + 1 then
    return true
  end

  return cmdpos <= prefix_boundary
end

function M.guard_prefix(key)
  return function()
    if is_protected_prefix_boundary() then
      return ""
    end

    return key
  end
end

return M
