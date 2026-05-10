local leader_groups = {
  -- nvim-treesitter-textobjects
  { "<leader>a", icon = { icon = "󰓡", color = "purple" } },
  { "<leader>A", icon = { icon = "󰓢", color = "purple" } },
  { "<leader>b", group = "Buffer", icon = { icon = "󰈔", color = "cyan" } },
  { "<leader>c", group = "Code", icon = { icon = "󰅩", color = "azure" } },
  { "<leader>d", group = "Diagnostics", icon = { icon = "", color = "yellow" } },
  { "<leader>f", group = "Find", icon = { icon = "󰍉", color = "blue" } },
  { "<leader>g", group = "Git", icon = { icon = "", color = "orange" } },
  { "<leader>gh", group = "Git hunk", icon = { icon = "", color = "orange" } },
  { "<leader>m", group = "Multicursor", icon = { icon = "󰆿", color = "purple" } },
  { "<leader>n", group = "Noice", icon = { icon = "󰎟", color = "cyan" } },
  { "<leader>o", group = "AI", icon = { icon = "󰚩", color = "green" } },
  { "<leader>r", group = "Refactor", icon = { icon = "󰑕", color = "purple" } },
  { "<leader>s", group = "Search", icon = { icon = "", color = "blue" } },
  { "<leader>t", group = "Terminal", icon = { icon = "", color = "green" } },
  { "<leader>T", group = "Test", icon = { icon = "󰙨", color = "green" } },
  { "<leader>u", group = "UI", icon = { icon = "󰙵", color = "cyan" } },
  { "<leader>x", group = "Trouble", icon = { icon = "", color = "red" } },
  { "<leader>z", group = "Fold", icon = { icon = "", color = "grey" } },
}

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    preset = "helix",
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(leader_groups)
  end,
}
