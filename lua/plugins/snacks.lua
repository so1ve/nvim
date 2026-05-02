return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = {},
    quickfile = {},
    picker = {},
    input = {},
    notifier = {},
    dashboard = {},
    indent = {},
    scroll = {},
    statuscolumn = {},
    terminal = {},
    rename = {},
    words = {},
  },
  config = function(_, opts)
    require("snacks").setup(opts)
  end,
  keys = {
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live grep" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
    { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notifications" },
    { "<leader>tt", function() Snacks.terminal() end, desc = "Toggle terminal" },
    { "<leader>tT", function() Snacks.terminal(nil, { win = { position = "float" } }) end, desc = "Toggle floating terminal" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename file" },
  },
}
