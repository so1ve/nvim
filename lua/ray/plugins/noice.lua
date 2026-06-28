return {
  {
    "folke/noice.nvim",
    lazy = false,
    priority = 900,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      cmdline = {
        enabled = false,
      },
      views = {
        mini = {
          position = {
            row = -2,
          },
          win_options = {
            winblend = 20,
          },
        },
        notify = {
          backend = "snacks",
        },
      },
      messages = {
        enabled = false,
      },
      popupmenu = {
        enabled = false,
      },
      notify = {
        view = "notify",
      },
      routes = {
        {
          filter = {
            event = "notify",
            error = true,
            find = "wakatime%-cli%.exe %-%-today",
          },
          opts = { skip = true },
        },
      },
      commands = {
        history = {
          filter = {
            any = {
              { event = "notify" },
              { error = true },
              { warning = true },
              { event = "msg_show", kind = { "", "echo", "echomsg", "lua_print", "list_cmd" } },
              { event = "lsp", kind = "message" },
            },
          },
        },
      },
      lsp = {
        message = {
          enabled = false,
        },
        progress = {
          enabled = false,
        },
        signature = {
          enabled = false,
        },
        hover = {
          enabled = false,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
          ["cmp.entry.get_documentation"] = false,
        },
      },
      presets = {
        long_message_to_split = true,
        lsp_doc_border = false,
      },
    },
    keys = {
      { "<leader>nh", "<cmd>Noice pick<cr>", desc = "Notification history" },
      { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss notifications" },
    },
    opts_extend = {
      "routes",
    },
  },
}
