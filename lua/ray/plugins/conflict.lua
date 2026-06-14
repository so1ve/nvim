return {
  "niekdomi/conflict.nvim",
  dependencies = {
    "nvimtools/hydra.nvim",
  },
  cmd = "Conflict",
  keys = {
    { "<leader>gc", desc = "Git Conflict Hydra" },
  },
  opts = {
    default_mappings = {
      current = false,
      incoming = false,
      both = false,
      base = false,
      none = false,
      next = false,
      prev = false,
    },
  },
  config = function(_, opts)
    local Hydra = require("ray.integrations.hydra")
    local conflict = require("conflict")

    conflict.setup(opts)

    Hydra({
      name = "Git Conflicts",
      mode = "n",
      body = "<leader>gc",
      heads = {
        {
          "n",
          function()
            conflict.navigate("next")
          end,
          { desc = "Next", group = "Move" },
        },
        {
          "p",
          function()
            conflict.navigate("prev")
          end,
          { desc = "Previous", group = "Move" },
        },
        { "r", "<cmd>Conflict refresh<cr>", { desc = "Refresh", group = "Move" } },
        {
          "c",
          function()
            conflict.choose("current")
          end,
          { desc = "Current", group = "Accept" },
        },
        {
          "i",
          function()
            conflict.choose("incoming")
          end,
          { desc = "Incoming", group = "Accept" },
        },
        {
          "b",
          function()
            conflict.choose("both")
          end,
          { desc = "Both", group = "Accept" },
        },
        {
          "B",
          function()
            conflict.choose("base")
          end,
          { desc = "Base", group = "Accept" },
        },
        { "l", conflict.list, { exit = true, desc = "Files", group = "Lists" } },
        { "Q", conflict.qflist, { exit = true, desc = "Quickfix", group = "Lists" } },
      },
    })
  end,
}
