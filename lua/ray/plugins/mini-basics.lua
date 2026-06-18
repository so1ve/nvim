return {
  "mini.basics",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  event = "UIEnter",
  config = function()
    require("mini.git").setup()
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.align").setup()
    require("mini.surround").setup()
    require("mini.jump").setup()

    local jump2d = require("mini.jump2d")
    local spotter =
      jump2d.gen_spotter.union(jump2d.builtin_opts.word_start.spotter, jump2d.gen_spotter.pattern(".+", "end"))
    jump2d.setup({
      spotter = spotter,
      labels = "abcdefghijklmnopqrstuvwxyz",
      view = { n_steps_ahead = 2 },
      allowed_windows = { not_current = false },
      mappings = { start_jumping = "<leader>j" },
    })

    require("mini.move").setup()
    require("mini.operators").setup({
      evaluate = { prefix = "" },
      exchange = { prefix = "gX" },
      multiply = { prefix = "gm" },
      replace = { prefix = "gR" },
      sort = { prefix = "" },
    })
    require("mini.trailspace").setup()
    require("mini.bracketed").setup({
      buffer = { suffix = "" },
      comment = { suffix = "" },
      file = { suffix = "" },
      treesitter = { suffix = "" },
    })
  end,
}
