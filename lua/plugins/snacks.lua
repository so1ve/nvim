local function open_trouble(picker, opts)
  require("trouble.sources.snacks").open(picker, opts)
end

local terminal = require("config.terminal")
local edgy = require("integrations.edgy")
local symbols = require("config.symbols")
local window_util = require("utils.windows")

local function delete_startup_buffers()
  -- Neo-tree popups and sidebar windows can trigger BufEnter while the dashboard
  -- is still the only real editor buffer. Cleanup only after entering an actual
  -- file window, otherwise Neovim may create a lingering [No Name] replacement.
  if not window_util.is_work_win(vim.api.nvim_get_current_win()) then
    return
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if window_util.is_dashboard(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    elseif window_util.is_empty_unnamed_file(bufnr) and vim.fn.bufwinid(bufnr) == -1 then
      -- Remove only hidden, never-edited [No Name] placeholders; visible buffers
      -- or modified scratch buffers are intentionally left alone.
      vim.api.nvim_buf_delete(bufnr, {})
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
      image = {},
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
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
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
      statuscolumn = {},
      terminal = {
        shell = terminal.shell and { terminal.shell.shell, terminal.shell.flag } or nil,
      },
      lazygit = {},
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
        "<leader>gg",
        function()
          Snacks.lazygit({ cwd = vim.fn.getcwd(0) })
        end,
        desc = "LazyGit",
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
          Snacks.picker.recent()
        end,
        desc = "Recent files",
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
        "<leader>gb",
        function()
          Snacks.picker.git_branches()
        end,
        desc = "Git branches",
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
