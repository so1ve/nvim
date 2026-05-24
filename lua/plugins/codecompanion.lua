local edgy = require("integrations.edgy")

return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "zbirenbaum/copilot.lua",
    },
    opts = {
      display = {
        action_palette = {
          provider = "snacks",
        },
      },
    },
    keys = {
      {
        "<leader>oc",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "x" },
        desc = "AI Chat",
      },
      {
        "<leader>oa",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "x" },
        desc = "AI action",
      },
      {
        "<leader>op",
        "<cmd>CodeCompanion<cr>",
        mode = { "n", "x" },
        desc = "Prompt inline AI",
      },
    },
  },
  edgy.view_spec("right", edgy.view("AI Chat", "codecompanion")),
}
