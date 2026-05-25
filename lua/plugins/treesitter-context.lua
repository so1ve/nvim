return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "so1ve/tiny-treesitter.nvim",
  },
  opts = {
    max_lines = 4,
    mode = "topline",
    multiline_threshold = 4,
  },
  keys = {
    {
      "gC",
      function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end,
      desc = "Go to sticky context",
    },
  },
}
