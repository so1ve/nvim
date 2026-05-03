return {
  "rcarriga/nvim-notify",
  lazy = false,
  priority = 999,
  opts = {
    background_colour = "#262626",
    minimum_width = 36,
    render = "compact",
    stages = "fade_in_slide_out",
    timeout = 3000,
    top_down = true,
  },
  config = function(_, opts)
    require("notify").setup(opts)
  end,
}
