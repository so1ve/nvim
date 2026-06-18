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

    local map_combo = require("mini.keymap").map_combo
    local combo_opts = { delay = vim.o.timeoutlen }
    for _, lhs in ipairs({ "jk", "jj" }) do
      map_combo("i", lhs, "<BS><BS><Esc>", combo_opts)
      map_combo("c", lhs, "<BS><BS><C-c>", combo_opts)
    end
    map_combo("t", "jk", "<BS><BS><C-\\><C-n>", combo_opts)
    map_combo({ "x", "s" }, "jk", "<BS><BS><Esc>", combo_opts)

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
