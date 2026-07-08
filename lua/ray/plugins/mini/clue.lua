local M = {}

function M.setup()
  local clue = require("mini.clue")
  local gen_clues = clue.gen_clues

  local objects = {
    { "=", "assignment" },
    { "/", "comment" },
    { "B", "buffer" },
    { "F", "call" },
    { "I", "indent" },
    { "a", "argument" },
    { "b", "block" },
    { "c", "class" },
    { "f", "function" },
    { "i", "conditional" },
    { "r", "return" },
    { "s", "statement" },
    { "(", "() block" },
    { ")", "() block" },
    { "[", "[] block" },
    { "]", "[] block" },
    { "{", "{} block" },
    { "}", "{} block" },
    { "<", "<> block" },
    { ">", "<> block" },
    { '"', '" string' },
    { "'", "' string" },
    { "`", "` string" },
    { "q", "quote" },
    { "t", "tag" },
    { "w", "word" },
    { "W", "WORD" },
    { "p", "paragraph" },
  }

  local object_prefixes = {
    { "a", "around " },
    { "i", "inside " },
    { "an", "around next " },
    { "in", "inside next " },
    { "al", "around last " },
    { "il", "inside last " },
  }

  local operator_targets = {
    { "w", "word" },
    { "W", "WORD" },
    { "$", "to line end" },
    { "0", "to line start" },
    { "^", "to first non-blank" },
    { "gg", "to file start" },
    { "G", "to file end" },
    { "%", "matching pair" },
    { "/", "search forward" },
    { "?", "search backward" },
    { "f", "find char forward" },
    { "F", "find char backward" },
    { "t", "till char forward" },
    { "T", "till char backward" },
  }

  local function ai_clues()
    local res = {
      { mode = { "o", "x" }, keys = "a", desc = "+Around" },
      { mode = { "o", "x" }, keys = "i", desc = "+Inside" },
      { mode = { "o", "x" }, keys = "an", desc = "+Around next" },
      { mode = { "o", "x" }, keys = "in", desc = "+Inside next" },
      { mode = { "o", "x" }, keys = "al", desc = "+Around last" },
      { mode = { "o", "x" }, keys = "il", desc = "+Inside last" },
    }
    for _, prefix in ipairs(object_prefixes) do
      for _, object in ipairs(objects) do
        res[#res + 1] = { mode = { "o", "x" }, keys = prefix[1] .. object[1], desc = prefix[2] .. object[2] }
      end
    end

    return res
  end

  local function operator_clues()
    local res = {}
    local operators = {
      { "d", "Delete" },
      { "y", "Yank" },
      { "c", "Change" },
    }

    for _, operator in ipairs(operators) do
      local key = operator[1]
      local action = operator[2]

      res[#res + 1] = { mode = "n", keys = key, desc = "+" .. action }
      res[#res + 1] = { mode = "n", keys = key .. key, desc = "line" }

      for _, target in ipairs(operator_targets) do
        res[#res + 1] = { mode = "n", keys = key .. target[1], desc = target[2] }
      end

      for _, prefix in ipairs(object_prefixes) do
        res[#res + 1] = { mode = "n", keys = key .. prefix[1], desc = "+" .. prefix[2] .. "textobject" }

        for _, object in ipairs(objects) do
          res[#res + 1] = {
            mode = "n",
            keys = key .. prefix[1] .. object[1],
            desc = prefix[2] .. object[2],
          }
        end
      end
    end

    return res
  end

  clue.setup({
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" },
      { mode = "n", keys = "d" },
      { mode = "n", keys = "y" },
      { mode = "n", keys = "c" },
      { mode = { "o", "x" }, keys = "a" },
      { mode = { "o", "x" }, keys = "i" },
      { mode = { "n", "x" }, keys = "g" },
      { mode = { "n", "x" }, keys = "z" },
      { mode = "n", keys = "<C-w>" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = { "n", "x" }, keys = "'" },
      { mode = { "n", "x" }, keys = "`" },
      { mode = { "n", "x" }, keys = '"' },
      { mode = "i", keys = "<C-x>" },
      { mode = { "i", "c" }, keys = "<C-r>" },
      { mode = { "n", "x" }, keys = "s" },
    },
    clues = {
      { mode = "n", keys = "<Leader>a", desc = "+AI" },
      { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
      { mode = "n", keys = "<Leader>c", desc = "+Code" },
      { mode = "n", keys = "<Leader>d", desc = "+Diagnostics" },
      { mode = "n", keys = "<Leader>f", desc = "+Find" },
      { mode = "n", keys = "<Leader>g", desc = "+Git" },
      { mode = "n", keys = "<Leader>gc", desc = "+Conflicts" },
      { mode = "n", keys = "<Leader>gcn", desc = "Next", postkeys = "<Leader>gc" },
      { mode = "n", keys = "<Leader>gcp", desc = "Previous", postkeys = "<Leader>gc" },
      { mode = "n", keys = "<Leader>gcr", desc = "Refresh", postkeys = "<Leader>gc" },
      { mode = "n", keys = "<Leader>gcc", desc = "Accept current", postkeys = "<Leader>gc" },
      { mode = "n", keys = "<Leader>gci", desc = "Accept incoming", postkeys = "<Leader>gc" },
      { mode = "n", keys = "<Leader>gcB", desc = "Accept both", postkeys = "<Leader>gc" },
      { mode = "n", keys = "<Leader>gcb", desc = "Accept base", postkeys = "<Leader>gc" },
      { mode = "n", keys = "<Leader>gcl", desc = "Files" },
      { mode = "n", keys = "<Leader>gcQ", desc = "Quickfix" },
      { mode = "n", keys = "<Leader>m", desc = "+Multicursor" },
      { mode = { "n", "x" }, keys = "<Leader>m<C-j>", desc = "Add cursor down", postkeys = "<Leader>m" },
      { mode = { "n", "x" }, keys = "<Leader>m<C-k>", desc = "Add cursor up", postkeys = "<Leader>m" },
      { mode = { "n", "x" }, keys = "<Leader>ma", desc = "Add all matches" },
      { mode = "n", keys = "<Leader>n", desc = "+Notifications" },
      { mode = "n", keys = "<Leader>o", desc = "+Overseer" },
      { mode = "n", keys = "<Leader>p", desc = "+Project" },
      { mode = "n", keys = "<Leader>q", desc = "+Quit / Buffer / Window" },
      { mode = "n", keys = "<Leader>r", desc = "+Refactor" },
      { mode = "n", keys = "<Leader>s", desc = "+Search" },
      { mode = "n", keys = "<Leader>t", desc = "+Terminal" },
      { mode = "n", keys = "<Leader>u", desc = "+UI" },
      { mode = "n", keys = "<Leader>x", desc = "+Trouble" },
      { mode = { "n", "x" }, keys = "<Leader>y", desc = "+Yank/Paste" },
      { mode = { "n", "x" }, keys = "s", desc = "+Surround" },

      gen_clues.builtin_completion(),
      ai_clues(),
      operator_clues(),
      gen_clues.g(),
      gen_clues.marks(),
      gen_clues.registers(),
      gen_clues.windows({
        submode_move = true,
        submode_navigate = true,
        submode_resize = true,
      }),
      gen_clues.square_brackets(),
      gen_clues.z(),
    },
    window = {
      delay = 300,
      config = {
        width = "auto",
      },
    },
  })
end

return M
