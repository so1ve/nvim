return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = {
    "nvimtools/hydra.nvim",
    "nvim-mini/mini.nvim",
  },
  keys = {
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer tab" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer tab" },
    { "<leader>b", desc = "Buffer Hydra" },
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
        return vim.bo[buffer].buftype == "" and vim.api.nvim_buf_get_name(buffer) ~= ""
      end,
    },
  },
  config = function(_, opts)
    local groups = require("bufferline.groups")
    local Hydra = require("integrations.hydra")

    opts.options.groups = {
      items = {
        groups.builtin.pinned:with({ icon = false }),
      },
    }
    opts.options.numbers = function(buffer)
      if groups._is_pinned({ id = buffer.id }) then
        return ""
      end
    end

    require("bufferline").setup(opts)

    Hydra({
      name = "Buffer",
      mode = "n",
      body = "<leader>b",
      heads = {
        { "h", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous", group = "Move" } },
        { "l", "<cmd>BufferLineCycleNext<cr>", { desc = "Next", group = "Move" } },
        { "b", "<cmd>BufferLinePick<cr>", { exit = true, desc = "Pick", group = "Move" } },
        { "d", "<cmd>BufferLinePickClose<cr>", { exit = true, desc = "Pick close", group = "Close" } },
        { "D", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close rest", group = "Close" } },
        { "L", "<cmd>BufferLineCloseLeft<cr>", { desc = "Close left", group = "Close" } },
        { "R", "<cmd>BufferLineCloseRight<cr>", { desc = "Close right", group = "Close" } },
        { "p", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin", group = "State" } },
      },
    })
  end,
}
