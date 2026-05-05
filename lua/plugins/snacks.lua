local function open_trouble(picker, opts)
  require("trouble.sources.snacks").open(picker, opts)
end

local windows = require("config.windows")

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = {},
    quickfile = {},
    picker = {
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
      enabled = false,
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
      sections = {
        { section = "header" },
        { section = "keys", padding = 1 },
        { title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
    indent = {},
    statuscolumn = {},
    terminal = {},
    lazygit = {},
    rename = {},
    words = {},
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    windows.setup_dashboard_lifecycle()
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
  },
}
