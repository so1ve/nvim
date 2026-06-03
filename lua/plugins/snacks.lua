local function open_trouble(picker, opts)
  require("trouble.sources.snacks").open(picker, opts)
end

local terminal = require("config.terminal")
local edgy = require("integrations.edgy")
local symbols = require("config.symbols")
local window_util = require("utils.windows")

local function has_non_dashboard_normal_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if window_util.is_normal_win(win) and not window_util.is_dashboard(vim.api.nvim_win_get_buf(win)) then
      return true
    end
  end

  return false
end

local function delete_startup_buffers()
  -- Dismiss the dashboard once any other non-floating window appears.
  if not has_non_dashboard_normal_window() then
    return
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if window_util.is_dashboard(bufnr) then
      Snacks.bufdelete({ buf = bufnr, force = true, wipe = true })
    end
  end
end

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
      dashboard = {
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua require('fff').find_files()" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua require('fff').live_grep()" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "s",
              desc = "Restore Session",
              action = ":lua require('plugins.mini.sessions').load()",
            },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua require('fff').find_files_in_dir(vim.fn.stdpath('config'))",
            },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
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
    config = function(_, opts)
      local snacks = require("snacks")

      require("patch.snacks.dashboard").patch()
      snacks.setup(opts)

      vim.api.nvim_create_autocmd("BufEnter", {
        desc = "Dismiss dashboard when entering a listed file buffer",
        callback = delete_startup_buffers,
      })

      delete_startup_buffers()
    end,
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
