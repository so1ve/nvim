local function open_trouble(picker, opts)
  require("trouble.sources.snacks").open(picker, opts)
end

local terminal = require("config.terminal")
local edgy = require("integrations.edgy")
local symbols = require("config.symbols")

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {},
      quickfile = {},
      picker = {
        sources = {
          lsp_symbols = {
            filter = symbols.snacks_lsp_symbol_filter(),
          },
          lsp_workspace_symbols = {
            filter = symbols.snacks_lsp_symbol_filter(),
          },
        },
        actions = {
          trouble_open = function(picker)
            open_trouble(picker)
          end,
          trouble_open_selected = function(picker)
            open_trouble(picker, { type = "selected" })
          end,
          trouble_open_all = function(picker)
            open_trouble(picker, { type = "all" })
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
      indent = {},
      scroll = {
        filter = function(buf)
          return vim.g.snacks_scroll ~= false
            and vim.b[buf].snacks_scroll ~= false
            and vim.bo[buf].filetype == "snacks_picker_preview"
        end,
      },
      statuscolumn = {},
      terminal = {
        shell = terminal.shell.shell and { terminal.shell.shell, terminal.shell.flag } or nil,
      },
      gh = {},
      rename = {},
      scope = {},
      words = {},
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
          Snacks.picker.lines()
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
        "<leader>fG",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git status",
      },
      {
        "<leader>tt",
        function()
          Snacks.terminal(nil, { count = 1, cwd = vim.fn.getcwd(0) })
        end,
        desc = "Toggle terminal",
      },
      {
        "<leader>tT",
        function()
          Snacks.terminal(nil, { count = 2, cwd = vim.fn.getcwd(0), win = { position = "float" } })
        end,
        desc = "Toggle floating terminal",
      },
      {
        "<leader>cR",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename file",
      },
      {
        "gS",
        function()
          Snacks.scope.jump()
        end,
        desc = "Go to scope",
      },
    },
  },
  edgy.view_spec(
    "bottom",
    edgy.view("Terminal", "snacks_terminal", {
      filter = function(_, win)
        local snacks_win = vim.w[win].snacks_win

        return snacks_win and snacks_win.position == "bottom" and snacks_win.relative == "editor"
      end,
    })
  ),
}
