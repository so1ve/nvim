return {
  "nvim-mini/mini.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    for _, module in ipairs(require("ray.utils.modules").load("ray.plugins.mini")) do
      module.setup()
    end
  end,
}
