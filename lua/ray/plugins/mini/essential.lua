local excluded_filetypes = {
  "bigfile",
  "gitcommit",
  "help",
  "markdown",
}

local M = {}

function M.setup()
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWinEnter", "FileType" }, {
    callback = function(event)
      local buf = event.buf
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      if vim.bo[buf].buftype ~= "" or vim.tbl_contains(excluded_filetypes, vim.bo[buf].filetype) then
        vim.b[buf].miniindentscope_disable = true
        vim.b[buf].minicursorword_disable = true
      end
    end,
  })

  local ai = require("mini.ai")
  local gen_ai_spec = require("mini.extra").gen_ai_spec
  local ts = ai.gen_spec.treesitter
  ai.setup({
    n_lines = 500,
    search_method = "cover",
    custom_textobjects = {
      ["="] = ts({ a = "@assignment.outer", i = "@assignment.inner" }),
      ["/"] = ts({ a = "@comment.outer", i = "@comment.inner" }),
      B = gen_ai_spec.buffer(),
      F = ts({ a = "@call.outer", i = "@call.inner" }),
      I = gen_ai_spec.indent(),
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
  require("mini.indentscope").setup({
    symbol = "│",
    draw = {
      animation = function()
        return 8
      end,
    },
    mappings = {
      object_scope = "",
      object_scope_with_border = "",
      goto_top = "",
      goto_bottom = "",
    },
  })

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

  require("ray.features.sessions").setup()
end

return M
