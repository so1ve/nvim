local function delete_buffer(buffer)
  Snacks.bufdelete(buffer)
end

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-mini/mini.nvim",
  },
  keys = {
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer tab" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer tab" },
    { "<leader>bb", "<cmd>BufferLinePick<cr>", desc = "Pick buffer tab" },
    { "<leader>bd", "<cmd>BufferLinePickClose<cr>", desc = "Pick close buffer tab" },
    { "<leader>bD", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffer tabs" },
    { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffer tabs left" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer tab" },
    { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffer tabs right" },
  },
  opts = {
    options = {
      max_name_length = 24,
      show_buffer_close_icons = false,

      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local icons = {
          error = " ",
          warning = " ",
          info = " ",
          hint = "󰌵 ",
        }

        return " " .. (icons[level] or "• ") .. count
      end,

      close_command = delete_buffer,
    },
  },
}
