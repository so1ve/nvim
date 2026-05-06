local M = {}
local modules = require("utils.modules")

function M.get(p)
  local groups = {}

  for _, module in ipairs(modules.load("colors.undefined.integrations")) do
    local integration = module.get(p)

    for group, spec in pairs(integration) do
      groups[group] = spec
    end
  end

  return groups
end

return M
