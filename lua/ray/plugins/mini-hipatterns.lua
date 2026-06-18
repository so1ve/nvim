local function todo_pattern(keyword)
  -- Match labels like `KEYWORD:` or `KEYWORD(...)`, but not dotted access like `vim.log.levels.WARN`.
  local suffix = "%s*[:%(]"

  return {
    "^()" .. keyword .. "()" .. suffix,
    "[^%.%w_]()" .. keyword .. "()" .. suffix,
  }
end

local function comment_group(group)
  return function(buf_id, _, data)
    for _, capture in ipairs(vim.treesitter.get_captures_at_pos(buf_id, data.line - 1, data.from_col - 1)) do
      if capture.capture:find("^comment") then
        return group
      end
    end
  end
end

local function todo_highlighter(keyword, group)
  return { pattern = todo_pattern(keyword), group = comment_group(group) }
end

return {
  "mini.hipatterns",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  event = "UIEnter",
  config = function()
    local hipatterns = require("mini.hipatterns")

    hipatterns.setup({
      highlighters = {
        hex_color = hipatterns.gen_highlighter.hex_color(),

        bug = todo_highlighter("BUG", "MiniHipatternsFixme"),
        fix = todo_highlighter("FIX", "MiniHipatternsFixme"),
        fixit = todo_highlighter("FIXIT", "MiniHipatternsFixme"),
        fixme = todo_highlighter("FIXME", "MiniHipatternsFixme"),
        hack = todo_highlighter("HACK", "MiniHipatternsHack"),
        info = todo_highlighter("INFO", "MiniHipatternsNote"),
        issue = todo_highlighter("ISSUE", "MiniHipatternsFixme"),
        note = todo_highlighter("NOTE", "MiniHipatternsNote"),
        optimize = todo_highlighter("OPTIMIZE", "MiniHipatternsPerf"),
        optim = todo_highlighter("OPTIM", "MiniHipatternsPerf"),
        passed = todo_highlighter("PASSED", "MiniHipatternsTest"),
        perf = todo_highlighter("PERF", "MiniHipatternsPerf"),
        performance = todo_highlighter("PERFORMANCE", "MiniHipatternsPerf"),
        test = todo_highlighter("TEST", "MiniHipatternsTest"),
        testing = todo_highlighter("TESTING", "MiniHipatternsTest"),
        todo = todo_highlighter("TODO", "MiniHipatternsTodo"),
        warn = todo_highlighter("WARN", "MiniHipatternsWarn"),
        warning = todo_highlighter("WARNING", "MiniHipatternsWarn"),
      },
    })
  end,
}
