local leader_groups = {
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>d", group = "diagnostics" },
  { "<leader>f", group = "find" },
  { "<leader>g", group = "git" },
  { "<leader>gh", group = "hunk" },
  { "<leader>m", group = "multicursor" },
  { "<leader>n", group = "noice" },
  { "<leader>o", group = "opencode" },
  { "<leader>s", group = "search" },
  { "<leader>t", group = "terminal" },
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
