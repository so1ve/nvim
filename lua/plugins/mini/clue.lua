local M = {}

local leader_clues = {
  { mode = "n", keys = "<Leader>c", desc = "+Code" },
  { mode = "n", keys = "<Leader>d", desc = "+Diagnostics" },
  { mode = "n", keys = "<Leader>f", desc = "+Find" },
  { mode = "n", keys = "<Leader>g", desc = "+Git" },
  { mode = "n", keys = "<Leader>gh", desc = "+Git hunk" },
  { mode = "n", keys = "<Leader>m", desc = "+Multicursor" },
  { mode = "n", keys = "<Leader>n", desc = "+Noice" },
  { mode = "n", keys = "<Leader>o", desc = "+AI" },
  { mode = "n", keys = "<Leader>r", desc = "+Refactor" },
  { mode = "n", keys = "<Leader>s", desc = "+Search" },
  { mode = "n", keys = "<Leader>t", desc = "+Terminal" },
  { mode = "n", keys = "<Leader>u", desc = "+UI" },
  { mode = "n", keys = "<Leader>x", desc = "+Trouble" },
  { mode = "n", keys = "<Leader>z", desc = "+Fold" },
}

function M.setup()
  local clue = require("mini.clue")
  local clues = vim.list_extend({}, leader_clues)

  vim.list_extend(clues, {
    clue.gen_clues.square_brackets(),
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
  })

  clue.setup({
    clues = clues,
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = "i", keys = "<C-x>" },
      { mode = { "n", "x" }, keys = "g" },
      { mode = { "n", "x" }, keys = "'" },
      { mode = { "n", "x" }, keys = "`" },
      { mode = { "n", "x" }, keys = '"' },
      { mode = { "i", "c" }, keys = "<C-r>" },
      { mode = "n", keys = "<C-w>" },
      { mode = { "n", "x" }, keys = "z" },
    },
    window = {
      delay = 300,
      config = {
        border = "rounded",
        width = "auto",
      },
    },
  })
end

return M
