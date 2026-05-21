return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    branch = true,
    need = 1,
  },
  keys = {
    {
      "<leader>pr",
      function()
        require("persistence").load()
      end,
      desc = "Restore project session",
    },
    {
      "<leader>ps",
      function()
        require("persistence").select()
      end,
      desc = "Select session",
    },
    {
      "<leader>pl",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore last session",
    },
    {
      "<leader>pd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't save session",
    },
  },
}
