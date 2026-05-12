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
        view_warn = "mini",
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
        command_palette = true,
        inc_rename = true,
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

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("RayNoiceHoverMovement", { clear = true }),
        desc = "Use visual-line movement in Noice hover windows",
        pattern = "noice_hover",
        callback = function(event)
          local keymap_opts = { buffer = event.buf, nowait = true, silent = true }

          vim.keymap.set("n", "j", "gj", vim.tbl_extend("force", keymap_opts, { desc = "Hover down visual line" }))
          vim.keymap.set("n", "k", "gk", vim.tbl_extend("force", keymap_opts, { desc = "Hover up visual line" }))
        end,
      })
    end,
  },
}
