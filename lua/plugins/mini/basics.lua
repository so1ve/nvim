local M = {}

function M.setup()
  local icons = require("mini.icons")
  icons.setup()
  icons.mock_nvim_web_devicons()

  require("mini.ai").setup({ n_lines = 500 })
  require("mini.surround").setup()
  require("mini.pairs").setup()
  require("mini.comment").setup()
  require("mini.move").setup()
  require("mini.splitjoin").setup()
  require("mini.bracketed").setup({
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
