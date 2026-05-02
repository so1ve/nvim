return {
  "SmiteshP/nvim-navic",
  main = "nvim-navic",
  opts = {
    highlight = true,
    separator = "  ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    icons = require("config.icons").symbols_with_padding(),
  },
}
