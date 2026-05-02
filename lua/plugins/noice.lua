return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    messages = {
      view = "mini",
      view_error = "mini",
      view_warn = "mini",
    },
    notify = {
      enabled = false,
    },
    lsp = {
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
    { "<leader>nl", function() require("noice").cmd("last") end, desc = "Noice last message" },
    { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice history" },
    { "<leader>na", function() require("noice").cmd("all") end, desc = "Noice all messages" },
    { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Dismiss Noice messages" },
  },
}
