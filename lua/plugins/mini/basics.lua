local M = {}

function M.setup()
  local icons = require("mini.icons")
  local hipatterns = require("mini.hipatterns")

  icons.setup()
  icons.mock_nvim_web_devicons()

  require("mini.ai").setup({ n_lines = 500 })
  require("mini.surround").setup()
  -- require("mini.jump").setup()
  require("mini.jump2d").setup({
    labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    view = { dim = true, n_steps_ahead = 2 },
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
  hipatterns.setup({
    highlighters = {
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end

return M
