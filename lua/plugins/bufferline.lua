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
      max_name_length = 24,
      show_buffer_close_icons = false,
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local severities = {
          error = vim.diagnostic.severity.ERROR,
          warning = vim.diagnostic.severity.WARN,
          info = vim.diagnostic.severity.INFO,
          hint = vim.diagnostic.severity.HINT,
        }
        local severity = severities[level]
        local icon = severity and require("config.diagnostics").sign(severity) or "•"

        return " " .. icon .. " " .. count
      end,
      close_command = function(buffer)
        Snacks.bufdelete(buffer)
      end,
      custom_filter = function(buffer)
        if vim.bo[buffer].buftype ~= "" then
          return false
        end
        if vim.api.nvim_buf_get_name(buffer) == "" then
          return false
        end

        return true
      end,
    },
  },
}
