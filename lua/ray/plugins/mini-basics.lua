return {
  "mini.basics",
  virtual = true,
  dependencies = {
    "nvim-mini/mini.nvim",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  event = "UIEnter",
  config = function()
    local ai = require("mini.ai")
    local ts = ai.gen_spec.treesitter
    ai.setup({
      n_lines = 500,
      custom_textobjects = {
        ["="] = ts({ a = "@assignment.outer", i = "@assignment.inner" }),
        ["/"] = ts({ a = "@comment.outer", i = "@comment.inner" }),
        F = ts({ a = "@call.outer", i = "@call.inner" }),
        a = ts({ a = "@parameter.outer", i = "@parameter.inner" }),
        b = ts({ a = "@block.outer", i = "@block.inner" }),
        c = ts({ a = "@class.outer", i = "@class.inner" }),
        f = ts({ a = "@function.outer", i = "@function.inner" }),
        i = ts({ a = "@conditional.outer", i = "@conditional.inner" }),
        r = ts({ a = "@return.outer", i = "@return.inner" }),
        -- intentional: use outer for both because inner is not consistent across languages
        s = ts({ a = "@statement.outer", i = "@statement.outer" }),
      },
    })

    require("mini.git").setup()
    require("mini.align").setup()
    require("mini.surround").setup()
    require("mini.jump").setup()
    require("mini.cursorword").setup({ delay = 0 })

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
    require("mini.misc").setup_restore_cursor()
    require("mini.trailspace").setup()
    require("mini.bracketed").setup({
      buffer = { suffix = "" },
      comment = { suffix = "" },
      file = { suffix = "" },
      treesitter = { suffix = "" },
    })
  end,
}
