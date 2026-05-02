return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 250,
    preset = "modern",
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.add({
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunk" },
      { "<leader>n", group = "noice" },
      { "<leader>o", group = "opencode" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "terminal" },
    })
  end,
}
