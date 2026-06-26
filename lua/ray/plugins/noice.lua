local rendered_doc_filetypes = { "noice_hover", "blink-cmp-documentation" }

local render_options = {
  render_modes = true,
  anti_conceal = { enabled = false },
  bullet = { enabled = true },
  checkbox = { enabled = false },
  code = { enabled = true },
  dash = { enabled = false },
  document = { enabled = false },
  heading = { enabled = true },
  html = { enabled = false },
  indent = { enabled = false },
  inline_highlight = { enabled = true },
  latex = { enabled = false },
  link = { enabled = false },
  paragraph = { enabled = false },
  pipe_table = { enabled = true },
  quote = { enabled = true },
  sign = { enabled = true },
}

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
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
    keys = {
      { "<leader>nh", "<cmd>Noice pick<cr>", desc = "Notification history" },
      { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss notifications" },
    },
    config = function(_, opts)
      for _, filetype in ipairs(rendered_doc_filetypes) do
        vim.treesitter.language.register("markdown", filetype)
      end

      require("ray.patch.noice").patch()
      require("noice").setup(opts)
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    ft = rendered_doc_filetypes,
    opts_extend = { "file_types" },
    opts = {
      file_types = rendered_doc_filetypes,
      overrides = {
        filetype = {
          ["noice_hover"] = render_options,
          ["blink-cmp-documentation"] = render_options,
        },
      },
    },
  },
}
