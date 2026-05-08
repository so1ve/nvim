return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      views = {
        mini = {
          win_options = {
            winblend = 20,
          },
        },
        notify = {
          backend = "snacks",
        },
      },
      messages = {
        view = "mini",
        view_error = "notify",
        view_warn = "mini",
      },
      notify = {
        view = "notify",
      },
      commands = {
        history = {
          filter = {
            any = {
              { event = "notify" },
              { error = true },
              { warning = true },
              { event = "msg_show", kind = { "", "list_cmd" } },
              { event = "lsp", kind = "message" },
            },
          },
        },
      },
      lsp = {
        message = {
          view = "mini",
        },
        progress = {
          view = "mini",
        },
        signature = {
          enabled = false,
        },
        hover = {
          silent = true,
          opts = {
            scrollbar = false,
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
}
