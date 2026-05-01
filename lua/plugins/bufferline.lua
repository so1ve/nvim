local function buffer_last_used(buffer)
  local info = vim.fn.getbufinfo(buffer.id)[1]

  if not info then
    return 0
  end

  return info.lastused or 0
end

local function buffer_id(buffer)
  return buffer.id or 0
end

local function mru_first(buffer_a, buffer_b)
  local a_pinned = buffer_a.pinned == true
  local b_pinned = buffer_b.pinned == true

  if a_pinned ~= b_pinned then
    return a_pinned
  end

  local a_last_used = buffer_last_used(buffer_a)
  local b_last_used = buffer_last_used(buffer_b)

  if a_last_used == b_last_used then
    return buffer_id(buffer_a) < buffer_id(buffer_b)
  end

  return a_last_used > b_last_used
end

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
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
      sort_by = mru_first,
      persist_buffer_sort = false,

      offsets = {
        {
          filetype = "neo-tree",
          text = "Files",
          text_align = "left",
          highlight = "Directory",
          separator = true,
        },
      },

      indicator = {
        icon = "▎",
        style = "icon",
      },
      separator_style = "thin",
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
