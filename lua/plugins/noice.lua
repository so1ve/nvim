local edgy = require("config.edgy")

local history_filter = {
  any = {
    { event = "notify" },
    { error = true },
    { warning = true },
    { event = "msg_show", kind = { "", "list_cmd" } },
    { event = "lsp", kind = "message" },
  },
}

return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      views = {
        mini = {
          win_options = {
            winblend = 0,
          },
        },
      },
      commands = {
        history = {
          filter = history_filter,
        },
        last = {
          filter = history_filter,
        },
      },
      lsp = {
        signature = {
          enabled = false,
        },
        hover = {
          silent = true,
          opts = {
            size = {
              max_height = 20,
              max_width = 100,
            },
          },
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
    keys = {
      { "<leader>nh", "<cmd>Noice pick<cr>", desc = "Notification history" },
      { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss notifications" },
    },
    config = function(_, opts)
      require("patch.noice").patch()
      require("noice").setup(opts)
    end,
  },
  edgy.neo_tree_exclusion_spec("noice"),
}
