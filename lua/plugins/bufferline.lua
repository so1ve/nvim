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
      mode = "buffers",

      offsets = {
        {
          filetype = "snacks_layout_box",
          text = "Explorer",
          text_align = "left",
          highlight = "Directory",
          separator = true,
        },
      },

      always_show_bufferline = true,
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_close_icon = true,
      show_duplicate_prefix = true,
      truncate_names = true,
      max_name_length = 24,
      max_prefix_length = 15,
      tab_size = 18,

      diagnostics = "nvim_lsp",
      diagnostics_update_on_event = true,
      diagnostics_indicator = function(count, level)
        local icons = {
          error = " ",
          warning = " ",
          info = " ",
          hint = "󰌵 ",
        }

        return " " .. (icons[level] or "• ") .. count
      end,

      close_command = "bdelete %d",
      right_mouse_command = "bdelete %d",
      left_mouse_command = "buffer %d",
      middle_mouse_command = nil,

      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
    },
  },
}
