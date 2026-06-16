return {
  "mini.icons",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  lazy = false,
  priority = 1000,
  config = function()
    local icons = require("mini.icons")

    icons.setup()
    icons.mock_nvim_web_devicons()
  end,
}
