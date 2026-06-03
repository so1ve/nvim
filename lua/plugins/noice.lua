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
        opts = {
          win_options = {
            winhighlight = {
              FloatTitle = "NoiceCmdlinePopupTitle",
            },
          },
        },
      },
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
        view_warn = "notify",
      },
      notify = {
        view = "notify",
      },
      routes = {
        {
          filter = {
            event = "notify",
            cond = function(message)
              return message.opts and message.opts.title == "Hardtime"
            end,
          },
          view = "notify",
          opts = { stop = true },
        },
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
            buf_options = {
              filetype = "noice_hover",
            },
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
      vim.treesitter.language.register("markdown", "noice_hover")

      require("patch.noice").patch()
      require("noice").setup(opts)
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    ft = "noice_hover",
    opts_extend = { "file_types" },
    opts = {
      file_types = { "noice_hover" },
      overrides = {
        filetype = {
          noice_hover = {
            render_modes = true,
            bullet = { enabled = false },
            checkbox = { enabled = false },
            code = { enabled = false },
            dash = { enabled = false },
            document = { enabled = false },
            heading = { enabled = true },
            html = { enabled = false },
            indent = { enabled = false },
            inline_highlight = { enabled = true },
            latex = { enabled = false },
            link = { enabled = false },
            paragraph = { enabled = false },
            pipe_table = { enabled = false },
            quote = { enabled = true },
            sign = { enabled = true },
          },
        },
      },
    },
  },
}
