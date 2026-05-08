local modules = require("utils.modules")

return {
  "nvim-mini/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    for _, module in ipairs(modules.load("plugins.mini")) do
      module.setup()
    end
  end,
}
