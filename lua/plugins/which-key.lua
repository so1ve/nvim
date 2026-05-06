local leader_groups = {
  -- nvim-treesitter-textobjects
  { "<leader>a", icon = { icon = "󰓡", color = "purple" } },
  { "<leader>A", icon = { icon = "󰓢", color = "purple" } },
  { "<leader>b", group = true, desc = "Buffer", icon = { icon = "󰈔", color = "cyan" } },
  { "<leader>c", group = true, desc = "Code", icon = { icon = "󰅩", color = "azure" } },
  { "<leader>d", group = true, desc = "Diagnostics", icon = { icon = "", color = "yellow" } },
  { "<leader>f", group = true, desc = "Find", icon = { icon = "󰍉", color = "blue" } },
  { "<leader>g", group = true, desc = "Git", icon = { icon = "", color = "orange" } },
  { "<leader>gh", group = true, desc = "Git hunk", icon = { icon = "", color = "orange" } },
  { "<leader>m", group = true, desc = "Multicursor", icon = { icon = "󰆿", color = "purple" } },
  { "<leader>n", group = true, desc = "Noice", icon = { icon = "󰎟", color = "cyan" } },
  { "<leader>o", group = true, desc = "AI", icon = { icon = "󰚩", color = "green" } },
  { "<leader>r", group = true, desc = "Refactor", icon = { icon = "󰑕", color = "purple" } },
  { "<leader>s", group = true, desc = "Search", icon = { icon = "", color = "blue" } },
  { "<leader>t", group = true, desc = "Terminal", icon = { icon = "", color = "green" } },
  { "<leader>u", group = true, desc = "UI", icon = { icon = "󰙵", color = "cyan" } },
  { "<leader>x", group = true, desc = "Trouble", icon = { icon = "", color = "red" } },
  { "<leader>z", group = true, desc = "Fold", icon = { icon = "", color = "grey" } },
}

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    preset = "modern",
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(leader_groups)
  end,
}
