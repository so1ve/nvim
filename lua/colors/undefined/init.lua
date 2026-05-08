local M = {}

function M.setup()
  vim.o.termguicolors = true

  if vim.g.colors_name then
    vim.cmd.highlight("clear")
  end

  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd.syntax("reset")
  end

  vim.g.colors_name = "undefined"

  local palette = require("colors.undefined.palette")
  local styles = require("colors.undefined.styles")
  local groups = require("colors.undefined.groups").get(palette)
  local integrations = require("colors.undefined.integrations").get(palette)

  for group, spec in pairs(integrations) do
    groups[group] = spec
  end

  styles.resolve_links(groups)

  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

return M
