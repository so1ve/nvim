local function toggle_explorer()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]

  if explorer then
    explorer:close()

    return
  end

  Snacks.explorer()
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    explorer = { enabled = true },
    quickfile = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          git_status = false,
          git_status_open = false,
          git_untracked = false,
        },
      },
    },
    input = { enabled = true },
    notifier = { enabled = true },
    dashboard = { enabled = true },
    indent = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    { "<leader>e", toggle_explorer, desc = "Toggle explorer" },
    { "<leader>E", function() Snacks.explorer.reveal() end, desc = "Reveal current file" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live grep" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
    { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notifications" },
  },
}
