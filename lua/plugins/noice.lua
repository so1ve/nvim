return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    messages = {
      view = "mini",
      view_error = "mini",
      view_warn = "mini",
    },
    notify = {
      enabled = true,
      view = "notify",
    },
    views = {
      hover = {
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        size = {
          max_height = 20,
          max_width = 100,
        },
      },
      mini = {
        win_options = {
          winblend = 0,
        },
      },
    },
    lsp = {
      hover = {
        silent = true,
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  },
  keys = {
    { "<leader>nh", "<cmd>Noice pick<cr>", desc = "Notification history" },
    { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss notifications" },
  },
}
