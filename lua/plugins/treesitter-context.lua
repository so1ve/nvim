return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    max_lines = 3,
    multiline_threshold = 3,
  },
  keys = {
    {
      "<leader>cc",
      function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end,
      desc = "Go to sticky context",
    },
  },
}
