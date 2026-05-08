local function open_trouble(picker, opts)
  require("trouble.sources.snacks").open(picker, opts)
end

local terminal = require("config.terminal")
local edgy = require("config.edgy")
local symbols = require("config.symbols")
local window_util = require("utils.windows")

local function snacks_position_filter(position)
  return function(_, win)
    local snacks_win = vim.w[win].snacks_win

    return snacks_win and snacks_win.position == position and snacks_win.relative == "editor"
  end
end

local function delete_dashboard_buffers()
  if not window_util.is_work_file(vim.api.nvim_get_current_buf()) then
    return
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if window_util.is_dashboard(bufnr) then
      pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    end
  end
end

local function register_dashboard_cleanup_autocmds()
  local group = vim.api.nvim_create_augroup("RaySnacksDashboardLifecycle", { clear = true })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    desc = "Dismiss dashboard when entering a listed file buffer",
    callback = delete_dashboard_buffers,
  })

  delete_dashboard_buffers()
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {},
      quickfile = {},
      explorer = {
        replace_netrw = false,
      },
      picker = {
        sources = {
          explorer = {
            auto_close = true,
            jump = { close = true },
            layout = { preset = "default", preview = false },
          },
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
        style = "compact",
      },
      dashboard = {
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
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
      require("snacks").setup(opts)
      register_dashboard_cleanup_autocmds()
    end,
    keys = {
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "LazyGit",
      },
      {
        "<leader>e",
        function()
          Snacks.picker.explorer()
        end,
        desc = "File explorer",
      },
      {
        "<leader>E",
        function()
          Snacks.picker.explorer({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "Explorer current file directory",
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
        "<leader>tt",
        function()
          Snacks.terminal()
        end,
        desc = "Toggle terminal",
      },
      {
        "<leader>tT",
        function()
          Snacks.terminal(nil, { win = { position = "float" } })
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
        "<leader>cs",
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
      filter = snacks_position_filter("bottom"),
    })
  ),
}
