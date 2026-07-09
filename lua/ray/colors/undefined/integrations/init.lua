local M = {}
local utils = require("ray.utils")

function M.get(p)
  local groups = {}

  for _, module in ipairs(utils.load("ray.colors.undefined.integrations")) do
    local integration = module.get(p)

    for group, spec in pairs(integration) do
      groups[group] = spec
    end
  end

  return groups
end

return M
