local M = {}

function M.extend(config, key, values)
  local keys = vim.split(key, ".", { plain = true })
  local target = config

  for _, part in ipairs(keys) do
    target[part] = target[part] or {}
    target = target[part]
  end

  return vim.list_extend(target, values)
end

return M
