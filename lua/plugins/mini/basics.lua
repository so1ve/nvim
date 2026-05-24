local M = {}

function M.setup()
  local icons = require("mini.icons")
  icons.setup()
  icons.mock_nvim_web_devicons()

  require("mini.ai").setup({ n_lines = 500 })
  require("mini.surround").setup()
  require("mini.jump").setup()
  require("mini.jump2d").setup({
    mappings = {
      start_jumping = "<leader>j",
    },
  })
  require("mini.move").setup()
  require("mini.operators").setup({
    evaluate = { prefix = "" },
    exchange = { prefix = "gX" },
    multiply = { prefix = "gm" },
    replace = { prefix = "gR" },
    sort = { prefix = "gs" },
  })
  require("mini.splitjoin").setup()
  require("mini.bracketed").setup({
    buffer = { suffix = "" },
    comment = { suffix = "" },
  })

  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })

  require("mini.trailspace").setup()
end

return M
