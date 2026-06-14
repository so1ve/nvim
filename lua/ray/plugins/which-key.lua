local diagnostic_icon = require("ray.config.diagnostics").sign(vim.diagnostic.severity.WARN)

local leader_groups = {
  { "<leader>b", group = "Buffer", icon = { icon = "󰈔", color = "cyan" } },
  { "<leader>c", group = "Code", icon = { icon = "󰅩", color = "azure" } },
  { "<leader>d", group = "Diagnostics", icon = { icon = diagnostic_icon, color = "yellow" } },
  { "<leader>f", group = "Find", icon = { icon = "󰍉", color = "blue" } },
  { "<leader>g", group = "Git", icon = { icon = "", color = "orange" } },
  { "<leader>gc", group = "Conflicts", icon = { icon = "", color = "red" } },
  { "<leader>m", group = "Multicursor", icon = { icon = "󰆿", color = "purple" } },
  { "<leader>n", group = "Noice", icon = { icon = "󰎟", color = "cyan" } },
  { "<leader>o", group = "Shell", icon = { icon = "󰔟", color = "purple" } },
  { "<leader>a", group = "AI", icon = { icon = "󰚩", color = "green" } },
  { "<leader>p", group = "Project", icon = { icon = "", color = "blue" } },
  { "<leader>q", group = "Quit / Buffer / Window", icon = { icon = "󰈆", color = "red" } },
  { "<leader>r", group = "Refactor", icon = { icon = "󰑕", color = "purple" } },
  { "<leader>s", group = "Search", icon = { icon = "", color = "blue" } },
  { "<leader>t", group = "Terminal", icon = { icon = "", color = "green" } },
  { "<leader>T", group = "Test", icon = { icon = "󰙨", color = "green" } },
  { "<leader>u", group = "UI", icon = { icon = "󰙵", color = "cyan" } },
  { "<leader>x", group = "Trouble", icon = { icon = "", color = "red" } },
}

local surround_groups = {
  { "s", group = "Surround", mode = { "n", "x" }, icon = { icon = "󰅪", color = "purple" } },
}

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    preset = "helix",
    triggers = {
      { "<auto>", mode = { "n", "x", "s", "o" } },
      { "s", mode = { "n", "x" } },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer keymaps",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(leader_groups)
    wk.add(surround_groups)
  end,
}
