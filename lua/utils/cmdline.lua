local M = {}

M.guard_commands = {
  "IncRename",
}

local function command_span(cmdline)
  return cmdline:find("^%s*(%S+)")
end

local function is_guarded_command(command)
  local normalized_command = command:gsub("!$", "")

  return vim.list_contains(M.guard_commands, normalized_command)
end

local function is_protected_prefix_boundary()
  if vim.fn.getcmdtype() ~= ":" then
    return false
  end

  local cmdline = vim.fn.getcmdline()
  local cmdpos = vim.fn.getcmdpos()
  local _, command_end, command = command_span(cmdline)

  if command == nil or not is_guarded_command(command) then
    return false
  end

  local prefix_boundary = command_end + 2

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
