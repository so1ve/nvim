local function todo_pattern(keyword)
  -- Match labels like `KEYWORD:` or `KEYWORD(...)`, but not dotted access like `vim.log.levels.WARN`.
  local suffix = "%s*[:%(]"

  return {
    "^()" .. keyword .. "()" .. suffix,
    "[^%.%w_]()" .. keyword .. "()" .. suffix,
  }
end

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

    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({
      highlighters = {
        hex_color = hipatterns.gen_highlighter.hex_color(),

        bug = { pattern = todo_pattern("BUG"), group = "MiniHipatternsFixme" },
        fix = { pattern = todo_pattern("FIX"), group = "MiniHipatternsFixme" },
        fixit = { pattern = todo_pattern("FIXIT"), group = "MiniHipatternsFixme" },
        fixme = { pattern = todo_pattern("FIXME"), group = "MiniHipatternsFixme" },
        hack = { pattern = todo_pattern("HACK"), group = "MiniHipatternsHack" },
        info = { pattern = todo_pattern("INFO"), group = "MiniHipatternsNote" },
        issue = { pattern = todo_pattern("ISSUE"), group = "MiniHipatternsFixme" },
        note = { pattern = todo_pattern("NOTE"), group = "MiniHipatternsNote" },
        optimize = { pattern = todo_pattern("OPTIMIZE"), group = "MiniHipatternsPerf" },
        optim = { pattern = todo_pattern("OPTIM"), group = "MiniHipatternsPerf" },
        passed = { pattern = todo_pattern("PASSED"), group = "MiniHipatternsTest" },
        perf = { pattern = todo_pattern("PERF"), group = "MiniHipatternsPerf" },
        performance = { pattern = todo_pattern("PERFORMANCE"), group = "MiniHipatternsPerf" },
        test = { pattern = todo_pattern("TEST"), group = "MiniHipatternsTest" },
        testing = { pattern = todo_pattern("TESTING"), group = "MiniHipatternsTest" },
        todo = { pattern = todo_pattern("TODO"), group = "MiniHipatternsTodo" },
        warn = { pattern = todo_pattern("WARN"), group = "MiniHipatternsWarn" },
        warning = { pattern = todo_pattern("WARNING"), group = "MiniHipatternsWarn" },
      },
    })
  end,
}
