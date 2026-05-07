local config = require("code-action-menu.config")
local lsp = require("code-action-menu.lsp")
local pickers = require("code-action-menu.pickers")
local utils = require("code-action-menu.utils")

local M = {}

function M.setup(opts)
  return config.setup(opts)
end

function M.code_action(opts)
  opts = vim.tbl_deep_extend("force", config.get(), opts or {})

  lsp.collect(opts, function(actions)
    if #actions == 0 then
      utils.notify("No code action available", vim.log.levels.INFO, opts)

      return
    end

    pickers.select(actions, opts, function(item)
      lsp.apply(item, opts)
    end)
  end)
end

return M
