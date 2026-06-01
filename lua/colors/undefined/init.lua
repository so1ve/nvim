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
  local function set_highlights(highlights)
    for group, spec in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, spec)
    end
  end

  set_highlights(require("colors.undefined.groups").get(palette))
  set_highlights(require("colors.undefined.integrations").get(palette))
end

return M
