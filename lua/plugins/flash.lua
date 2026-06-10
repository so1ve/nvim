return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    labels = "asdfghjklqwertyuiopzxcvbnm",
    highlight = {
      backdrop = false,
    },
    label = {
      uppercase = false,
    },
    modes = {
      char = {
        enabled = true,
        highlight = { backdrop = false },
        jump_labels = false,
      },
    },
  },
  keys = {
    {
      "<leader>j",
      function()
        require("flash").jump({
          jump = { autojump = true },
          search = { multi_window = false },
        })
      end,
      desc = "Flash jump",
      mode = { "n", "x", "o" },
    },
    {
      "<leader>J",
      function()
        require("flash").treesitter()
      end,
      desc = "Flash treesitter",
      mode = { "n", "x", "o" },
    },
    {
      "r",
      function()
        require("flash").remote()
      end,
      desc = "Remote flash",
      mode = "o",
    },
  },
}
