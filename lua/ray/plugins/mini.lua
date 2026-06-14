local modules = require("ray.utils.modules")

return {
  "nvim-mini/mini.nvim",
  event = "UIEnter",
  config = function()
    for _, module in ipairs(modules.load("ray.plugins.mini")) do
      module.setup()
    end
  end,
}
