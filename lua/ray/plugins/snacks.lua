local symbols = require("ray.config.symbols")

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {},
      dashboard = { enabled = false },
      quickfile = {},
      picker = {
        sources = {
          files = {
            hidden = true,
          },
          lsp_symbols = {
            filter = symbols.snacks_lsp_symbol_filter,
          },
          lsp_workspace_symbols = {
            filter = symbols.snacks_lsp_symbol_filter,
          },
        },
        actions = {
          trouble_open = function(picker)
            require("trouble.sources.snacks").open(picker)
          end,
          trouble_open_selected = function(picker)
            require("trouble.sources.snacks").open(picker, { type = "selected" })
          end,
          trouble_open_all = function(picker)
            require("trouble.sources.snacks").open(picker, { type = "all" })
          end,
        },
        win = {
          input = {
            keys = {
              ["<C-t>"] = { "trouble_open", mode = { "n", "i" } },
            },
          },
        },
      },
      input = {},
      notifier = {
        height = { min = 1, max = 0.4 },
      },
      styles = {
        notification = {
          ft = "snacks_notif",
        },
      },
      statuscolumn = {},
      gh = {},
      rename = {},
      words = { enabled = false },
    },
    keys = {
      {
        "<leader>gb",
        function()
          Snacks.picker.git_branches()
        end,
        desc = "Git branches",
      },
      {
        "<leader>gi",
        function()
          Snacks.picker.gh_issue()
        end,
        desc = "GitHub Issues (open)",
      },
      {
        "<leader>gI",
        function()
          Snacks.picker.gh_issue({ state = "all" })
        end,
        desc = "GitHub Issues (all)",
      },
      {
        "<leader>gp",
        function()
          Snacks.picker.gh_pr()
        end,
        desc = "GitHub Pull Requests (open)",
      },
      {
        "<leader>gP",
        function()
          Snacks.picker.gh_pr({ state = "all" })
        end,
        desc = "GitHub Pull Requests (all)",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>fu",
        function()
          Snacks.picker.undo()
        end,
        desc = "Undo history",
      },
      {
        "<leader>fd",
        function()
          Snacks.picker.diagnostics_buffer()
        end,
        desc = "Buffer diagnostics",
      },
      {
        "<leader>fD",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Workspace diagnostics",
      },
      {
        "<leader>fk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>fc",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>f:",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command history",
      },
      {
        "<leader>fl",
        function()
          local buf = vim.api.nvim_get_current_buf()

          Snacks.picker.pick({
            finder = function()
              local extmarks = require("snacks.picker.util.highlight").get_highlights({ buf = buf, extmarks = true })
              local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
              local items = {}

              for lnum, line in ipairs(lines) do
                items[#items + 1] = {
                  buf = buf,
                  text = line,
                  pos = { lnum, (line:find("%S") or 1) - 1 },
                  highlights = extmarks[lnum],
                }
              end

              return items
            end,
            format = "lines",
            title = "Buffer Lines",
            layout = {
              layout = {
                backdrop = 60,
              },
            },
          })
        end,
        desc = "Search current buffer",
      },
      {
        "<leader>f/",
        function()
          Snacks.picker.search_history()
        end,
        desc = "Search history",
      },
      {
        "<leader>nh",
        function()
          Snacks.picker.notifications()
        end,
        desc = "Notification history",
      },
      {
        "<leader>nd",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss notifications",
      },
      {
        "<leader>fG",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git status",
      },
      {
        "<leader>cR",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename file",
      },
    },
  },
}
