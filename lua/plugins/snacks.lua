local function toggle_explorer()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]

  if explorer then
    explorer:close()

    return
  end

  Snacks.explorer()
end

local function open_explorer_on_startup()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  if vim.bo.buftype ~= "" or vim.fn.expand("%") == "" then
    return
  end

  vim.schedule(function()
    Snacks.explorer()
  end)
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = {},
    explorer = {},
    quickfile = {},
    picker = {
      sources = {
        explorer = {
          git_status = false,
          git_status_open = false,
          git_untracked = false,
        },
      },
    },
    input = {},
    notifier = {},
    dashboard = {},
    indent = {},
    scroll = {},
    statuscolumn = {},
    words = {},
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      group = vim.api.nvim_create_augroup("RaySnacksExplorer", { clear = true }),
      desc = "Open Snacks explorer after opening a file",
      once = true,
      callback = open_explorer_on_startup,
    })
  end,
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
