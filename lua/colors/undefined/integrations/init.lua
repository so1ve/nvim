local M = {}

local modules = {
  "mini",
  "snacks",
  "gitsigns",
  "bufferline",
  "blink",
  "noice",
  "treesitter-context",
  "rainbow-delimiters",
  "opencode",
}

function M.get(p)
  local groups = {}

  for _, module in ipairs(modules) do
    local integration = require("colors.undefined.integrations." .. module).get(p)

    for group, spec in pairs(integration) do
      groups[group] = spec
    end
  end

  return groups
end

return M
